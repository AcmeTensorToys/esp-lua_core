-- DEPENDS: file, mdns, net, rtctime, sjson, sntp, wifi; nwfnet, nwfnet-sntp
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(t)
  (require "nwfnet"):runnet("wstagoip",t)
  if mdns then mdns.register(wifi.sta.gethostname()) end
  OVL["nwfnet-sntp"]().dosntp(nil)
end)
wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function(_) (require "nwfnet"):runnet("wstadtmo") end)
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(t) (require "nwfnet"):runnet("wstaconn",t) end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(t) (require "nwfnet"):runnet("wstadscn",t) end)

-- do this before wifi because for some unknown reason it clobbers the
-- configuration state.  I suspect that this is an SDK bug.
if file.open("nwfnet.cert","r") then
  local cert = ""
  local chunk = file.read()
  while chunk ~= nil do cert = cert..chunk; chunk = file.read() end
  ok, res = pcall(net.cert.verify,cert)
  file.close()
  if ok then
    print("Loaded cert from nwfnet.cert, which will now be removed.")
    file.remove("nwfnet.cert")
  else
    print("Failed to load from nwfnet.cert", res)
  end
end

-- Connection configuration options
--
-- While these things could be persisted by the ESP, it's probably simpler to
-- keep them in a file instead.
if file.open("nwfnet.conf","r") then
  local conf = sjson.decode(file.read() or "")
  if type(conf) == "table" then

    local essid, pw = conf["sta_essid"], conf["sta_pw"]
    if essid ~= nil and pw ~= nil then
      wifi.sta.config({['ssid'] = essid, ['pwd'] = pw, save=false})
    end

    if conf["ap"] ~= nil then pcall(wifi.ap.config,conf["ap"]) end
    -- XXX Don't really support softap yet, so...
    -- local ccok = false
    -- if conf["cc"] ~= nil then ccok = pcall(wifi.setcountry,conf["cc"]) end

    local modestr = conf["wifi_mode"]
    if     modestr == "station"         then wifi.setmode(wifi.STATION)
    -- XXX Don't really support softap yet, so...
    -- elseif modestr == "softap" and ccok then wifi.setmode(wifi.SOFTAP)
    elseif modestr == "stationap"       then wifi.setmode(wifi.STATIONAP)
    else                                     wifi.setmode(wifi.STATION)
    end

    if conf["sntp"] then
      (require "nwfnet").sntp = conf["sntp"]
    end

    if conf["tls_verify"] == 1 then
      pcall(net.cert.verify,true)
    end

   else print("nwfnet.conf malformed")
  end
  file.close()
end
-- must come after we've got our event callbacks registered, yeah?
wifi.sta.connect()
