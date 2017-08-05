local function dosntp(server)
  local nn = require "nwfnet"
  if not server then
    if file.open("nwfnet.conf2","r") then
      local conf = sjson.decode(file.read() or "")
      if type(conf) == "table" then
        if conf["sntp"]  then server = conf["sntp"] end
       else print("nwfnet.conf2 malformed")
  end end end
  -- XXX Soon, in upstream, the NTP module will default to a ntp pool;
  -- we should just let that happen here, when that happens!
  local x, y
  if not server then x, y, server = wifi.ap.getip() end
  if not server then x, y, server = wifi.sta.getip() end
  if not server then nn:runnet("sntperr", "No sntp server?") return end
  sntp.sync(server,
     function(sec,usec,server) rtctime.set(sec,usec); nn:runnet("sntpsync",sec,usec,server) end,
     function(err) nn:runnet("sntperr",err) end
  )
end

local self = {}
self.dosntp = dosntp
return self
