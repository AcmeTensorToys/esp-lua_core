-- DEPENDS: i2c, i2cu
-- cap1188 based heavily on adafruit's documentation and code as well as the
-- device datasheet.  Unsurprising, really, esp. that it's their breakout.
local self = {}
self.bus = 0
self.addr = 0x29

local i2cu = require "i2cu"

function self:rr(r)
  local x = i2cu.wr(self.bus, self.addr, 1, r)
  return x:byte(1)
end

function self:wr(r,v)
  return i2cu.writen(self.bus, self.addr, r, v)
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
