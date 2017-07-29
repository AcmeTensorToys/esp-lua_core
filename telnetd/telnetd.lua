-- DEPEND: net ; fifosock
local self = {}
self.commands = { ["echo"] = function(r,s) s(r) end }
function self.tryin(i,ft,nc,ns,...) -- input, function table, no-command, no-space, args
  local ix = i:find("%f[%s]",1,false)
  if (ix ~= nil) then
    local c, r = i:sub(1,ix-1), i:sub(ix+1); local cf = ft[c]
    if cf ~= nil then cf(r,...) else nc(c,r,...) end
  else ns(i,...)
  end
end
self.on = { ["conn"] = nil, ["disconn"] = nil }
local function tryon(e,...) local c = self.on[e]; if c ~= nil then c(...) end end
function self.rx(tx,input,k)
  self.tryin(input, self.commands,
    function(c,r)
      if c == "quit" then k(false) else
       local rt = loadfile(string.format("telnetd-%s.lc",c))
       if rt ~= nil
        then self.tryin(r,rt(),function(c2) tx(c.." "..c2.."?") end, function() tx(c.." ??") end,tx)
        else tx(c.."?")
       end
       k(true)
      end
    end,
    function(_) tx("?") k(true) end,tx)
end
function self.server(sock_)
  local fsend = (dofile("fifosock.lc"))((require "fifo")(), sock_)
  local function teardown(rawsock)
    rawsock:on("sent", nil)
    rawsock:on("receive", nil)
    rawsock:on("disconnection", nil)
    tryon("disconn",fsend)
  end
  sock_:on("receive",function(s_,input) self.rx(fsend,input,function(c) if c then fsend("\n$ ") else s_:close() teardown(s_) end end) end)
  sock_:on("disconnection",function(s_, x) teardown(s_) end)
  tryon("conn",fsend)
  fsend("\n$ ")
end
return self
