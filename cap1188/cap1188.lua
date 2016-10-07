-- DEPENDS: i2c
-- cap1188 based heavily on adafruit's documentation and code as well as the
-- device datasheet.  Unsurprising, really, esp. that it's their breakout.
local self = {}
self.addr = 0x29

function self:rr(r)
  i2c.start(0)
  if not i2c.address(0, self.addr, i2c.TRANSMITTER) then i2c.stop(0) return nil end
   i2c.write(0,r)
  i2c.start(0)
   i2c.address(0,0x29,i2c.RECEIVER)
   local x = i2c.read(0,1)
  i2c.stop(0)
  return x:byte(1)
end

function self:wr(r,v)
  i2c.start(0)
  if not i2c.address(0, self.addr, i2c.TRANSMITTER) then i2c.stop(0) return nil end
  i2c.write(0,r)
  i2c.write(0,v)
  i2c.stop(0)
  return true
end

function self:mr(r,f) local n = f(self:rr(r)) ; self:wr(r,n); return n end

function self:rt()
  local t = self:rr(0x3)
  self:mr(0, function(st) return bit.band(st,0xFE) end)
  local t2 = self:rr(0x3)
  return t, t2
end

function self:info()
  return self:rr(0xFD), self:rr(0xFE), self:rr(0xFF)
end

return self
