return function(tq, pin, addr, power, k)
 local function doread()
  ow.reset(pin)
  ow.select(pin, addr)
  ow.write(pin,0xBE,power)

  local data = string.char(ow.read(pin))
  for i = 1, 8 do data = data .. string.char(ow.read(pin)) end

  if data:byte(9) == ow.crc8(string.sub(data,1,8))
   then k(data:byte(1) + 256*data:byte(2))
   else k(nil)
  end
 end

 ow.reset(pin)
 ow.select(pin, addr)
 ow.write(pin, 0x44, power)
 tq:queue(1000,doread)
end
