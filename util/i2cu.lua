local self = {}

function self.readn(addr, len)
  i2c.start(0)
  if not i2c.address(0, addr, i2c.RECEIVER) then i2c.stop(0) return nil end
  local v = i2c.read(0, len)
  i2c.stop(0)
  return v
end

function self.writen(addr, ...)
  i2c.start(0)
  if not i2c.address(0, addr, i2c.TRANSMITTER) then i2c.stop(0) return nil end
  i2c.write(0, ...)
  i2c.stop(0)
  return true
end

return self
