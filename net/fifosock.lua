-- Wrap a two-staged fifo around a socket's send, borrowing TerryE's
-- scheme from NodeMCU's lua_examples/telnet/telnet.lua .

local BIGTHRESH = 256   -- how big is a "big" string?
local SPLITSLOP = 16    -- any slop in the big question?
local FSMALLLIM = 32    -- maximum number of small strings held

local concat = table.concat
local insert = table.insert

local fifo = OVL.fifo()

return function(sock)
  local ssend  = function(s) sock:send(s) end
  local fsmall, lsmall, fbig = {}, 0, fifo()

  -- Move fsmall to fbig; might send if fbig empty
  local function promote()
    if #fsmall == 0 then return end
    local str = concat(fsmall)
    fsmall, lsmall = {}, 0
    fbig:queue(str, ssend)
  end

  local function sendnext()
    if not fbig:dequeue(ssend) then promote() end
  end

  sock:on("sent", sendnext)

  return function(s)
    -- don't sweat the petty things
    if s == nil or s == "" then return end

    -- small fifo would overfill?  promote it
    if lsmall + #s > BIGTHRESH or #fsmall >= FSMALLLIM then promote() end

    -- big string?  chunk and queue big components immediately
    -- behind any promotion that just took place
    while #s > BIGTHRESH + SPLITSLOP do
     local pfx
     pfx, s = s:sub(1,256), s:sub(257)
     fbig:queue(pfx, ssend)
    end

    -- Big string?  queue
    if #s > BIGTHRESH then fbig:queue(s, ssend)
    -- small and empty line; start txing now.  (no corking)
    elseif fbig._go and lsmall == 0 then fbig:queue(s, ssend)
    -- small and queue already moving
    else insert(fsmall, s) ; lsmall = lsmall + #s
    end
  end
end
