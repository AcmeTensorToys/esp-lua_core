-- DEPENDS: fifo, file, mqtt, sjson; nwfnet
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
    local mprime = {}

    m:on("connect", function(_) nwfnet:runnet("mqttconn",mprime) end)
    m:on("offline", function(_) nwfnet:runnet("mqttdscn",mprime) end)
    m:on("message", function(_,t,m) nwfnet:runmqtt(mprime,t,m,false) end)
    m:on("overflow", function(_) nwfnet:runnet(mprime,t,m,true) end)

    local fifoc = require "fifo"
    local function unthunk(thunk) thunk() end
    local sfifo = fifoc.new()
    local ufifo = fifoc.new()
    local pfifo = fifoc.new()

    m:on("puback"  , function() pfifo:dequeue(unthunk) end)
    m:on("suback"  , function() sfifo:dequeue(unthunk) end)
    m:on("unsuback", function() ufifo:dequeue(unthunk) end)

    mprime.close       = function(_,...) m:close()          end -- indirect
    mprime.lwt         = function(_,...) m:lwt(...)         end -- indirect
    mprime.connect     = function(_,...) m:connect(...)     end -- indirect
    mprime.subscribe   = function(_,...)
        local t = { ... }
        sfifo:queue(function() m:subscribe(unpack(t)) end, unthunk)
      end
    mprime.unsubscribe = function(_,...)
        local t = { ... }
        ufifo:queue(function() m:unsubscribe(unpack(t)) end, unthunk)
      end
    mprime.publish     = function(_,...)
        local t = { ... }
        pfifo:queue(function() m:publish(unpack(t)) end, unthunk)
      end

    return mprime, u, c
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
  secure = secure or 0
  return m:connect(broker,port,secure)
end
function self.suball(m,fn) -- subscribe to all lines in a file
  if file.open(fn) then
    local line
    for line in function() return file.readline() end do m:subscribe(line:sub(1,-2),1) end
    file.close()
  end
end
return self
