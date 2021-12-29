local function dosntp(server)
  local nwo = OVL and OVL["sntp"]

  if nwo then
    nwo = nwo()
    -- new world order?
    nwo.go((require "nwfnet").sntp, nil,
      function(res, serv, self)
	local sec, usec = rtctime.get()
	local nn = require"nwfnet" -- XXX why must this be broken out?
	nn:runnet("sntpsync",sec,usec,serv)
      end,
      function(err, srv, rply)
	local nn = require"nwfnet"
	if err == "all" then nn:runnet("sntperr","No SNTP available") end
      end)
  elseif sntp then
    -- old world order
    local function try()
    pcall(sntp.sync,(require "nwfnet").sntp,
      function(sec,usec,server) rtctime.set(sec,usec); (require"nwfnet"):runnet("sntpsync",sec,usec,server) end,
      function(err) (require"nwfnet"):runnet("sntperr",err) end)
    end
    try()
    cron.schedule("*/5 * * * *", try)
  end
end

local self = {}
self.dosntp = dosntp
return self
