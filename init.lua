-- DEPEND: gpio, node, rtctime?, tmr ; nwfnet, nwfnet-diag, nwfnet-go, telnetd

-- An "overlay" table: load files or flash components in a way
-- that, unlike require, doesn't cause them to "stick" in RAM.
--
-- Based on lua_examples/lfs/_init.lua
local G=_ENV or getfenv()
local flashindex = (node.LFS and node.LFS.get) or node.flashindex
local ovl_t = {
  __index = function(_, name)
      local f = loadfile(name..".lua")
      if f then return f end
      local f = loadfile(name..".lc")
      if f then return f end
      if flashindex then return flashindex(name) end
      return nil
    end,
  __newindex = function(_, name, value)
      error("Overlay is a synthetic view! " .. name, 2)
    end,
  }
G.OVL = setmetatable(ovl_t,ovl_t)

-- Install LFS as a package loader, as suggested by lua_examples/lfs/_init.lua
if flashindex then table.insert(package.loaders,flashindex) end

-- Save some bytes, as suggested by lua_examples/lfs/_init.lua
package.seeall = nil

if rtctime then rtctime.set(0) end -- set time to 0 until someone corrects us

-- See if there's any early startup to do.
local ie = OVL["init-early"]
if ie then pcall(ie) end

local gotmr = tmr.create()
got = gotmr

local function goab()
    OVL["nwfnet-diag"]()(true)
    OVL["diag"]()
    OVL["nwfnet-go"]()
    tcpserv = net.createServer(net.TCP, 180)
    tcpserv:listen(23,function(k)
          local telnetd = OVL["telnetd"]()
          telnetd.on["conn"] = function(s)
              if gotmr then gotmr:stop() ; gotmr = nil end
              s(string.format("NODE-%06X RECOVERY (auto reboot cancelled)",node.chipid()))
          end
          telnetd.server(k)
        end)
end
local function goi2()
  local i2 = OVL.init2
  if not i2 then goab() else node.task.post(i2) end
end
local function waitFLASH()
    local function stop_()
      gpio.mode(3,gpio.INPUT); gpio.trig(3)
      gotmr:stop(); got = nil; gotmr = nil
      stop = nil; go = nil
    end
    function stop() stop_(); goab() end
    function go() print("Continuing boot..."); stop_(); goi2() end
    print("Reset delay!  Bounce GPIO3 low or type 'stop()' to stop autoboot, or 'go()' to go...")
    gpio.mode(3,gpio.INT,gpio.PULLUP)
    gotmr:alarm(8000,tmr.ALARM_SINGLE,go)
    gpio.trig(3,"low",function(_) print("Aborting..."); stop() end)
end
local function bootPANIC()
  print("Panic!  Lingering for a minute with telnet console up; 'stop()' to persist...")
  gotmr:alarm(60000,tmr.ALARM_SINGLE,node.restart)
  function stop() gotmr:stop() end
  goab()
end
local bct = {
  [0] = waitFLASH, -- power on
  [1] = bootPANIC, -- hardware watchdog
  [2] = bootPANIC, -- exception
  [3] = bootPANIC, -- software watchdog
  [4] = waitFLASH, -- software reset
  [5] = goi2,      -- deep sleep
  [6] = waitFLASH, -- external reset
}
local _, bc = node.bootreason()
if bct[bc] then bct[bc]() else waitFLASH() end
