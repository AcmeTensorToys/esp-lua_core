local self = {}
local i2c = i2c

function self.probe(bus, addr)
  i2c.start(bus)
  local res = i2c.address(bus, addr, i2c.RECEIVER)
  i2c.stop(bus)
  return res
end

function self.readn(bus, addr, len)
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.RECEIVER) then i2c.stop(bus) return nil end
  local v = i2c.read(bus, len)
  i2c.stop(bus)
  return v
end

function self.writen(bus, addr, ...)
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.TRANSMITTER) then i2c.stop(bus) return nil end
  i2c.write(bus, ...)
  i2c.stop(bus)
  return true
end

-- write/read without a full stop/start (no risk of losing arbitration)
function self.wr(bus, addr, len, ...)
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.TRANSMITTER) then i2c.stop(bus) return nil end
  i2c.write(bus, ...)
  i2c.start(bus) -- "repeated start"
  if not i2c.address(bus, addr, i2c.RECEIVER) then i2c.stop(bus) return nil end
  local v = i2c.read(bus, len)
  i2c.stop(bus)
  return v
end

return self
