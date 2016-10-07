-- Just callback registries
local nwfnet   = {}
  -- possible events: wstaconn, wstagoip, wstadscn, wstadtmo; sntpsync, sntperr ; mqttconn, mqttdscn
nwfnet.onnet   = {}
  -- specifically mqtt message events
nwfnet.onmqtt  = {}
function nwfnet:runnet(e,...) for _,v in pairs(nwfnet.onnet) do v(e,...) end end
function nwfnet:runmqtt(...) for _,v in pairs(nwfnet.onmqtt) do v(...) end end
return nwfnet
