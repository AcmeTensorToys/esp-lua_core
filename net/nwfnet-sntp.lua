local function dosntp(server)
  sntp.sync((require "nwfnet").sntp,
     function(sec,usec,server) rtctime.set(sec,usec); (require"nwfnet"):runnet("sntpsync",sec,usec,server) end,
     function(err) (require"nwfnet"):runnet("sntperr",err) end
  )
end

local self = {}
self.dosntp = dosntp
return self
