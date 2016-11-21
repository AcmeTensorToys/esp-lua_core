return function(q)
  local k,v
  print("FIFOQ")
  for k,v in ipairs(q) do print("",k,v) end
end
