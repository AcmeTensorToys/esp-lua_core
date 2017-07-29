-- Wrap a fifo around a socket's send
return function(fifo,sock)
  local function dosend(s) sock:send(s) end
  sock:on("sent", function() fifo:dequeue(dosend) end)

  return function(s)
    if s == nil or s == "" then return end
    fifo:queue(s,dosend)
  end
end
