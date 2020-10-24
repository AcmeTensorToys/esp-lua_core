local self = {}

function self.readn(bus, addr, len)
  local i2c = i2c
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.RECEIVER) then i2c.stop(bus) return nil end
  local v = i2c.read(bus, len)
  i2c.stop(bus)
  return v
end

function self.writen(bus, addr, ...)
  local i2c = i2c
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.TRANSMITTER) then i2c.stop(bus) return nil end
  i2c.write(bus, ...)
  i2c.stop(bus)
  return true
end

-- write/read without a full stop/start
function self.wr(bus, addr, len, ...)
  local i2c = i2c
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.TRANSMITTER) then i2c.stop(bus) return nil end
  i2c.write(bus, ...)
  i2c.start(bus)
  if not i2c.address(bus, addr, i2c.RECEIVER) then i2c.stop(bus) return nil end
  local v = i2c.read(bus, len)
  i2c.stop(bus)
  return v
end

return self
