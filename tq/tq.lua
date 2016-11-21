-- DEPENDS: tmr [only by default]
local fire, doarm
function fire(self)
  local cbt = {}
  local entryt = self:now()
  local lapsed = (entryt - self._tst)/1000
  if #self._q > 0 and lapsed < self._q[1].t then
    -- premature fire?  adjust and rearm
    self._q[1].t = self._q[1].t - lapsed
    doarm(self, self._q[1].t)
    return
  end
  while #self._q > 0 and self._q[1].t <= lapsed do
    -- collect events in the past into cbt
    local cbs = table.remove(self._q,1)
    lapsed = lapsed - cbs.t
    table.insert(cbt,cbs)
  end
  if #self._q > 0 then
    -- leftover events: credit excess lapsed time and rearm
    self._q[1].t = self._q[1].t - lapsed
    doarm(self, self._q[1].t)
  end
  -- run all collected callbacks, having adjusted queue
  local k, cbs, v
  for k,cbs in ipairs(cbt) do for k,v in ipairs(cbs) do v() end end
end
function doarm(self,when) self:arm(function() fire(self) end, when); self._tst = self:now() end
local function queue(self,when,what,...)
  if #self._q > 0 then
    local lapsed = (self:now() - self._tst)/1000
    self._q[1].t = self._q[1].t - lapsed
  end
  local ix = 0; local tleft = when
  while (ix < #self._q) do
    if (tleft < self._q[ix+1].t) then break end
    ix = ix + 1; tleft = tleft - self._q[ix].t
  end
  local warg = {...}; local nwarg = select('#',...)
  local wfn = function () return what(unpack(warg,1,nwarg)) end
  if ix == 0 then doarm(self,when)
  elseif tleft == 0 then table.insert(self._q[ix],wfn); return
  end
  table.insert(self._q,ix+1,{["t"] = tleft, [1] = wfn})
  if ix+1 < #self._q then
    self._q[ix+2].t = self._q[ix+2].t - tleft
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
