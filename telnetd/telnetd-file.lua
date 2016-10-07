-- DEPENDS: encoder, file, net
local function withfat(s,m,fn,off,k)
    if not file.open(fn,m) then s("ERR: Cannot open file "..fn.." "..m); return end
    if file.seek("set", tonumber(off)) == nil then s("ERR: Cannot seek file"); file.close(); return end
    k()
    file.close()
end
return {
  ["info"] = function(ll,s) local rem, use, _ = file.fsinfo(); s(string.format("use=%d rem=%d",use,rem)) end
, ["list"] = function(ll,s) for k,v in pairs(file.list()) do s(string.format("%s %d\n",k,v)) end end
, ["remove"]  = function(ll,s) local fn = string.match(ll,"^%s*([^%s]+)%s*$"); file.remove(fn)  end
, ["compile"] = function(ll,s) local fn = string.match(ll,"^%s*([^%s]+)%s*$");
    local r,err = pcall(node.compile,fn); if not r then s("ERR: "..err) end
  end
, ["pread"] = function(ll,s) -- read b64 data from off in fn
    local len, off, fn = string.match(ll,"^%s*(%d+)%s+(%d+)%s+([^%s]+)%s*$")
    if fn == nil then s("ERR: Need file"); return end
    withfat(s,"r",fn,off,function()
        local out = file.read(tonumber(len))
        if out == nil then s("ERR: Read err"); return end
        s(encoder.toBase64(out))
    end)
  end
, ["pwrite"] = function(ll,s) -- write b64 data at off in fn
    local off, fn, edat = string.match(ll,"^%s*(%d+)%s+([^%s]+)%s*([^%s]+)%s*$")
    if edat == nil then s("ERR: Malformed command"); return end
    local ddat, err = encoder.fromBase64(edat)
    if ddat == nil then s("ERR: "..err); return end
    if tonumber(off) == 0 and not file.exists(fn) then file.open(fn,"w"); file.close() end
    withfat(s,"r+",fn,off,function() if file.write(ddat) == nil then s("ERR: Write error") else s("OK") end end)
  end
, ["cert"] = function(ll,s) -- load argument as certificate root
    local fn = string.match(ll,"^%s*([^%s]+)%s*$")
    withfat(s,"r",fn,0,function()
      local cert = ""
      local chunk = file.read()
      while chunk ~= nil do cert = cert..chunk; chunk = file.read() end
      net.cert.verify(cert)
    end)
  end
}
