-- DEPENDS: ; nwfnet
return function(ena)
  local nn = require "nwfnet"
  if ena then
    nn.onmqtt["diag"] = function(...) print('mqttmsg',...) end
    nn.onnet["diag"] = function(e,...)
      if     e == "wstagoip" then local t = ... ; print(e,t.IP,t.netmask,t.gateway)
      elseif e == "wstaconn" then local t = ... ; print(e,t.SSID,t.BSSID,t.channel)
      elseif e == "wstadscn" then local t = ... ; print(e,t.SSID,t.BSSID,t.reason)
      else print(e,...) end
    end
  else
    nn.onmqtt["diag"] = nil
    nn.onnet["diag"] = nil
  end
end
