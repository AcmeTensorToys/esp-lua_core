-- STATELESS
--
-- Wrap a socket object so that it queues sends.  Must call :fini after
-- done to avoid a memory leak (that I don't understand in full)
--
-- Ideally, import this once, wrap all the sockets you need, and then forget
-- it.  If one needs new sockets periodically, it is unclear to me whether
-- it's better to load this once and hold it in RAM or to load it every
-- time.
return function(fifo,sock)
  local function dosend(s) sock:send(s) end
  sock:on("sent", function() fifo:dequeue(dosend) end)

  local nsock = {}
  function nsock.send(_,s)
    if s == nil or s == "" then return end
    fifo:queue(s,dosend)
  end
  function nsock.fini(_) sock = nil end
  local sockit = getmetatable(sock)["__index"]
  setmetatable(nsock,{ __index = function(_,k)
    local fn = sockit[k]
    return function(a,...) if a == nsock then fn(sock,...) else fn(a,...) end end
  end })
  return nsock
end
