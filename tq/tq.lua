-- DEPENDS: tmr [only by default]
local fire, doarm
function fire(self)
  local cbs = table.remove(self._q,1)
  if #self._q > 0 then doarm(self, self._q[1]["t"]) end
  local v
  for _,v in ipairs(cbs) do v() end
end
function doarm(self,when) self:arm(function() fire(self) end, when); self._tst = self:now() end
local function queue(self,when,what,...)
  if #self._q > 0 then
    local lapsed = (self:now() - self._tst)/1000
    self._q[1]["t"] = self._q[1]["t"] - lapsed
  end
  local ix = 0; local tleft = when
  while (ix < #self._q) do
    if (tleft < self._q[ix+1]["t"]) then break end
    ix = ix + 1; tleft = tleft - self._q[ix]["t"]
  end
  local warg = {...}; local nwarg = select('#',...)
  local wfn = function () return what(unpack(warg,1,nwarg)) end
  if ix == 0 then doarm(self,when)
  elseif tleft == 0 then table.insert(self._q[ix],wfn); return
  end
  table.insert(self._q,ix+1,{["t"] = tleft, [1] = wfn})
  if ix+1 < #self._q then
    self._q[ix+2]["t"] = self._q[ix+2]["t"] - tleft
  end
  return wfn
end
local function dequeue(self,what)
  local k,v,w
  for _,v in pairs(self._q) do for k,w in ipairs(v) do
    if w == what then table.remove(v,k) end
  end end
end
local function defl_arm(self,fn,t) tmr.alarm(self.tmr, t, tmr.ALARM_SINGLE, fn) end
local function defl_now(_) return tmr.now() end
return function(tmrix) return {
  _q = {}, _tst = 0,
  ["arm"] = defl_arm, ["now"] = defl_now, ["tmr"] = tmrix, ["queue"] = queue, ["dequeue"] = dequeue
} end
