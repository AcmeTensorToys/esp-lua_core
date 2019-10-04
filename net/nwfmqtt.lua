-- DEPENDS: fifo, file, mqtt, sjson; nwfnet
local nwfnet = require "nwfnet"
local self = {}

-- wrap an existing mqtt client.  This serializes the command directives
-- (pub/sub/unsub) while making the callbacks useful on a per-call basis and
-- pushes the asynchronous callbacks (connect/disconn/message/overflow) over
-- the nwfnet broadcast chains (runnet/runmqtt).  An optional second argument
-- can replace the default global nwfnet chains.
--
-- The underlying C implementation does not do well with multiple
-- outstanding requests of the same sort.  In order to permit modular
-- use of a mqtt connection, serialize and handle callbacks here.  A single
-- fifo is used to reduce memory overhead.
--
-- This makes heavy use of the fifo module and its replacement and phantom
-- element facilities: each command is queued as a thunk on the fifo and,
-- when popped, replaces itself with a thunk for its callback (if present).
-- This latter thunk signals to the fifo that it is phantom, thereby
-- advancing the queue to the next command, if any.

function self.wrap(m, nn) 
  local mprime = {}

  nn = nn or require "nwfnet"

  m:on("connect", function(_) nn:runnet("mqttconn",mprime) end)
  m:on("offline", function(_) nn:runnet("mqttdscn",mprime) end)
  m:on("message", function(_,t,p) nn:runmqtt(mprime,t,p,false) end)
  m:on("overflow", function(_,t,p) nn:runmqtt(mprime,t,p,true) end)

  local cfifo = (require "fifo").new()
  local function unthunk(thunk) return thunk() end
  local function cfifodq() cfifo:dequeue(unthunk) end

  m:on("puback"  , cfifodq)
  m:on("suback"  , cfifodq)
  m:on("unsuback", cfifodq)

  mprime._m          = m
  mprime._f          = cfifo
  mprime.close       = function(mp,...) mp._m:close()          end -- indirect
  mprime.lwt         = function(mp,...) mp._m:lwt(...)         end -- indirect
  mprime.connect     = function(mp,...) mp._m:connect(...)     end -- indirect

  mprime.subscribe   = function(mp, a1, a2, a3)
      if type(a1) == "table" then
        mp._f:queue(function()
          mp._m:subscribe(a1)
          return (a2 and function() a2(mp); return nil, true end)
        end, unthunk)
      else
        mp._f:queue(function()
          mp._m:subscribe(a1, a2)
          return (a3 and function() a3(mp); return nil, true end)
        end, unthunk)
      end
    end
  mprime.unsubscribe = function(mp, tt, cb)
      mp._f:queue(function()
        mp._m:unsubscribe(tt)
        return (cb and function() cb(mp); return nil, true end)
      end, unthunk)
    end
  mprime.publish     = function(mp, t, p, q, r, cb)
      mp._f:queue(function()
        mp._m:publish(t, p, q, r)
        return (cb and function() cb(mp); return nil, true end)
      end, unthunk)
    end

  return mprime
end

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

    return self.wrap(m), u, c
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
