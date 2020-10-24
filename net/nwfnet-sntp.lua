local function dosntp(server)
  local nwo = OVL and OVL["sntp"]

  if nwo then
    nwo = nwo()
    -- new world order?
    nwo.go((require "nwfnet").sntp, nil,
      function(res, serv, self)
	local sec, usec = nil, nil -- rtctime.get()
        (require"nwfnet"):runnet("sntpsync",sec,usec,serv)
      end,
      function(err, srv, rply)
	if err == "all" then (require"nwfnet"):runnet("sntperr","No SNTP available") end
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
