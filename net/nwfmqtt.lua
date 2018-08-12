-- DEPENDS: file, mqtt, sjson; nwfnet
local nwfnet = require "nwfnet"
local self = {}
function self.mkclient(cf) -- construct a client with config from json file cf
  local c, k, u, p, l
  if file.open(cf) then
    local conf = sjson.decode(file.read() or "")
    if type(conf) == "table" then
      c = conf["clientid"]; k = conf["keepalive"]; u = conf["user"]; p = conf["pass"]; l = conf["clean"]
    end
    file.close()
    if not u or not p then return nil end
    c = c or string.format("NODE-%06X",node.chipid())
    k = k or 1500
    l = l or 0
    local m = mqtt.Client(c,k,u,p,l)
    m:on("connect", function(c) nwfnet:runnet("mqttconn",c) end)
    m:on("offline", function(c) nwfnet:runnet("mqttdscn",c) end)
    m:on("message", function(c,t,m) nwfnet:runmqtt(c,t,m) end)
    return m, u, c
  end
  return nil
end
function self.connect(m,cf) -- make a connection with parameters from json file cf
  local broker, port, secure
  if file.open(cf) then
    local conf = sjson.decode(file.read() or "")
    if type(conf) == "table" then
      broker = conf["broker"]; port = conf["port"]; secure = conf["secure"]
    end
    file.close()
  end
  conf = nil
  broker = broker or "iot.eclipse.org"
  port = port or 1883
  secure = (secure == 1) or 0
  return m:connect(broker,port,secure,0)
end
function self.suball(m,fn) -- subscribe to all lines in a file
  if file.open(fn) then
    local line
    for line in function() return file.readline() end do m:subscribe(line:sub(1,-2),1) end
    file.close()
  end
end
return self
