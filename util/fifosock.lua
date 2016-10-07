-- STATELESS
local fs = {}
function fs.wrap(sock)
  local sf = {}
  local sfe = true
  local function sfd() if #sf > 0 then sock:send(table.remove(sf,1)) else sfe = true end end
  sock:on("sent", sfd)
  local nsock = {}
  nsock.send = function(k,s)
    if s == nil or s == "" then return end
    table.insert(sf,s)
    if sfe then sfe = false; sfd() end
  end
  nsock.fini = function() sf=nil; sock=nil end
  local sockit = getmetatable(sock)["__index"]
  setmetatable(nsock,{ __index = function(_,k)
    local fn = sockit[k]
    return function(a,...) if a == nsock then fn(sock,...) else fn(a,...) end end
  end })
  return nsock
end
return fs
