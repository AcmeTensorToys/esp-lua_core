-- DEPEND: file?, gpio, node, rtctime?, tmr ; nwfnet, nwfnet-diag, nwfnet-go, telnetd
if rtctime then rtctime.set(0) end -- set time to 0 until someone corrects us

-- XXX much of this framework calls cjson as such; that should be fixed
if not cjson then _G.cjson = sjson end

-- See if there's any early startup to do.
if file and file.exists("init-early.lua") then dofile("init-early.lua") end

local function goab()
	dofile("nwfnet-diag.lc")(true)
	dofile("diag.lc")
	dofile("nwfnet-go.lc")
	tcpserv = net.createServer(net.TCP, 180)
        tcpserv:listen(23,function(k)
          local telnetd = dofile "telnetd.lc"
	  telnetd.on["conn"] = function(k)
            tmr.unregister(6)
            k:send(string.format("NODE-%06X RECOVERY (auto reboot cancelled)",node.chipid())) end
          telnetd.server(k)
        end)
end
local function go(fn) 
	local f, e = loadfile(fn)
	if f == nil then print("Error:",fn,e); goab() else node.task.post(f) end
end
local function goi2() go("init2.lc") end
local function waitFLASH()
	local function stop_() gpio.mode(3,gpio.INPUT); gpio.trig(3); tmr.unregister(6); stop = nil end
        function stop() stop_(); goab(); end
	print("Reset delay!  Bounce GPIO3 low or type 'stop()' to stop autoboot...")
	gpio.mode(3,gpio.INT,gpio.PULLUP)
	tmr.alarm(6,8000,tmr.ALARM_SINGLE,function() print("Continuing boot..."); stop_(); goi2() end)
	gpio.trig(3,"low",function(_) print("Aborting..."); stop() end)
end
local function bootPANIC()
  print("Panic!  Lingering for five minutes with telnet console up; 'tmr.unregister(6)' to persist...")
  tmr.alarm(6,300000,tmr.ALARM_SINGLE,node.restart)
  goab()
end
local bct = { [0] = waitFLASH, [1] = bootPANIC, [2] = bootPANIC, [3] = bootPANIC, [4] = waitFLASH, [5] = goi2, [6] = waitFLASH }
local _, bc = node.bootreason()
if bct[bc] then bct[bc]() else waitFLASH() end
