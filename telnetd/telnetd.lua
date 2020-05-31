-- DEPEND: net; pipe

local M = {}

M.commands = { ["echo"] = function(r,s) s(r) end }
function M.tryin(i,ft,nc,ns,...) -- input, function table, no-command, no-space, args
  local ix = i:find("%f[%s]",1,false)
  if (ix ~= nil) then
    local c, r = i:sub(1,ix-1), i:sub(ix+1); local cf = ft[c]
    if cf ~= nil then cf(r,...) else nc(c,r,...) end
  else ns(i,...)
  end
end
M.on = { ["conn"] = nil, ["disconn"] = nil }

local function tryon(e,...) local c = M.on[e]; if c ~= nil then c(...) end end

function M.rx(tx,input,k)
  M.tryin(input, M.commands,
    function(c,r)
      if c == "quit" then k(false) else
       local rt = OVL["telnetd-"..c]
       if type(rt) == 'function'
        then M.tryin(r,rt(),function(c2) tx(c.." "..c2.."?") end, function() tx(c.." ??") end,tx)
        else tx(c.."?")
       end
       k(true)
      end
    end,
    function(_) tx("?") k(true) end,tx)
end

-- called with an ESTABLISHED TCP socket
function M.server(sock)

  -- upval: sock
  local function opipe_cb(opipe)
    local resp = opipe:read(1400)
    if resp and #resp > 0 then sock:send(resp) end
    return false -- block pipe until onsent_cb
  end

  -- opipe points at opipe_cb, points at sock.
  local opipe = pipe.create(opipe_cb)
  local function opw(s) opipe:write(s) end

  -- upval: opipe, opipe_cb
  --
  -- so now sock points at onsent_cb which transitively points back at sock;
  -- a circularity through the registry.  This must be manually broken, which
  -- we do in teardown or will happen when net kills off the connection due to
  -- timeout.
  local function onsent_cb(sock_)
    -- sock_ == sock; we're already circular anyway, no reason to use sock_
    opipe_cb(opipe)
  end

  local ipipe

  -- upval: ipipe, opipe, tryon
  local function teardown(rawsock)
    if rawsock then
      rawsock:on("sent", nil)
      rawsock:on("receive", nil)
      rawsock:on("disconnection", nil)
    end
    tryon("disconn",nil)
    opipe = nil
    ipipe = nil
  end

  -- upval: M, sock, teardown, opw
  local function ipipe_cb(i)
    local inp = i:read('\n+')
    if inp and inp:sub(-1) == "\n"
     then M.rx(opw, inp,
                function(c) if c
                             then opw("\n$ ")
                             else sock:close() teardown(sock)
                            end
                end)
     elseif inp then i:unread(inp)
     else return false
    end
  end

  ipipe = pipe.create(ipipe_cb)

  -- upval: ipipe
  sock:on("receive",function(s_,input) ipipe:write(input) end)

  -- upval: teardown
  sock:on("disconnection",function(s_, x) teardown(s_) end)
  tryon("conn", opw)
  opw("\n$ ")
end

return M
