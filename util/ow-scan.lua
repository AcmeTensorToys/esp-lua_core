return function(pin, reset)
  local x = {}
  local addr = nil
  if reset then
   ow.reset(pin)
   ow.reset_search(pin)
  end
  repeat
    addr = ow.search(pin)
    x[#x+1] = addr
  until (addr == nil) or (#x > 10)
  return x
end
