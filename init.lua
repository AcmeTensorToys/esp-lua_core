-- DEPEND: file?, gpio, node, rtctime?, tmr ; nwfnet, nwfnet-diag, nwfnet-go, telnetd
if rtctime then rtctime.set(0) end -- set time to 0 until someone corrects us

-- See if there's any early startup to do.
if file and file.exists("init-early.lua") then dofile("init-early.lua") end

local function goab()
    dofile("nwfnet-diag.lc")(true)
    dofile("diag.lc")
    dofile("nwfnet-go.lc")
    tcpserv = net.createServer(net.TCP, 180)
    tcpserv:listen(23,function(k)
          local telnetd = dofile "telnetd.lc"
          telnetd.on["conn"] = function(s)
              tmr.unregister(6)
              s(string.format("NODE-%06X RECOVERY (auto reboot cancelled)",node.chipid()))
          end
          telnetd.server(k)
        end)
end
local function gof(fn)
    local f, e = loadfile(fn)
    if f == nil then print("Error:",fn,e); goab() else node.task.post(f) end
end
local function goi2() gof("init2.lc") end
local function waitFLASH()
    local function stop_()
      gpio.mode(3,gpio.INPUT); gpio.trig(3); tmr.unregister(6)
      stop = nil; go = nil
    end
    function stop() stop_(); goab() end
    function go() print("Continuing boot..."); stop_(); goi2() end
    print("Reset delay!  Bounce GPIO3 low or type 'stop()' to stop autoboot, or 'go()' to go...")
    gpio.mode(3,gpio.INT,gpio.PULLUP)
    tmr.alarm(6,8000,tmr.ALARM_SINGLE,go)
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
