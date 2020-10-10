-- A very minimal HT16K33 driver, fitting for such a minimal chip!

local M = {}

local function tx(self, ...)
  local i2c, bus, addr = i2c, self.bus, self.addr
  i2c.start(bus)
  i2c.address(bus, addr, i2c.TRANSMITTER) 
  i2c.write(bus, ...)
  i2c.stop(bus)
end

local function txrx(self, w, rn)
  local i2c, bus, addr = i2c, self.bus, self.addr
  i2c.start(bus)
  i2c.address(bus, addr, i2c.TRANSMITTER) 
  i2c.write(bus, w)
  i2c.start(bus)
  i2c.address(bus, addr, i2c.TRANSMITTER) 
  local ret = i2c.read(rn)
  i2c.stop(bus)
  return ret
end

-- control the primary oscillator
local function osc(self,on)
  return tx(self, on and 0x21 or 0x20)
end
M.osc = osc

M.BLINK_NONE = 0
M.BLINK_2HZ  = 1
M.BLINK_1HZ  = 2
M.BLINK_05HZ = 3
local function conf(self, blink, on)
  return tx(self, 0x80 + (blink*2) + (on and 1 or 0))
end
M.conf = conf

M.KEYROW_ROW = 0
M.KEYROW_INT_LO = 1
M.KEYROW_INT_HI = 3
function M:rowint(how) -- configure last row as row or interrupt
  return tx(self, 0xA0 + how)
end

-- Set brightness between 0 (which is not off, just dim) and 15
function M:dim(bright)
  return tx(self, 0xE0 + bright)
end

-- write what (str int or string with #str <= 16) where (default to 0, 0 to 15)
--
-- Recall that device display memory is organized by COM then ROW: the first
-- byte here is COM0 ROW0 (LSB) through COM0 ROW7 (MSB), then COM0 ROW8 (LSB)
-- through COM0 ROW15 (MSB), then COM1 ROW0 (LSB) through COM1 ROW7 (MSB), etc.
function M:write(what, where)
  where = where or 0x00
  if type(what) == "table"
   then return tx(self, where, table.unpack(what))
   else return tx(self, where, what)
  end
end

function M:readint()
  return txrx(self, "\096", 1)
end

function M:readkey()
  return txrx(self, "\064", 5)
end

local function blank(self)
  self:write("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
end
M.blank = blank

-- a convenience method for default initialization
function M:init()
  osc(self, true)
  blank(self)
  conf(self, 0, true)
end

M.__index = M

return function(bus, addr)
  local self = setmetatable({}, M)
  self.bus, self.addr = bus, addr

  return self
end
