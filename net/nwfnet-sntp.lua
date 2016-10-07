local function dosntp(server)
  local nn = require "nwfnet"
  if not server then
    if file.open("nwfnet.conf2","r") then
      local conf = cjson.decode(file.read())
      if type(conf) == "table" then
        if conf["sntp"]   then print("Setting SNTP server"); server = conf["sntp"] end
       else print("nwfnet.conf2 malformed")
  end end end
  local x, y
  if not server then x, y, server = wifi.ap.getip() end
  if not server then x, y, server = wifi.sta.getip() end
  if not server then nn:runnet("sntperr", "No sntp server?") return end
  sntp.sync(server,
     function(sec,usec,server) rtctime.set(sec,usec); nn:runnet("sntpsync",sec,usec,server) end,
     function(err) nn:runnet("sntperr",err) end
  )
end

local function loopsntp(tq,period,server)
  local function f() dosntp(server); tq:queue(period,f) end
  tq:queue(period,f)
end

local self = {}
self.dosntp = dosntp
self.loopsntp = loopsntp
return self
