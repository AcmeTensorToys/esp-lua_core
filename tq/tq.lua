-- DEPENDS: tmr [only by default]
local function fire(self)
  local entryt = self:now()
  local lapsed = (entryt > self._tst) and (entryt - self._tst)/1000 or 0
  if #self._q > 0 and lapsed < self._q[1].t then
    -- premature fire?  adjust and rearm
    self._q[1].t = self._q[1].t - lapsed
    self._tst = entryt
    self:arm(self._q[1].t, entryt)
    return
  end
  local cbt = {}
  while #self._q > 0 and self._q[1].t <= lapsed do
    -- collect events in the past into cbt
    local cbs = table.remove(self._q,1)
    lapsed = lapsed - cbs.t
    table.insert(cbt,cbs)
  end
  if #self._q > 0 then
    -- leftover events: credit excess lapsed time and rearm
    self._q[1].t = self._q[1].t - lapsed
    self._tst = entryt
    self:arm(self._q[1].t, entryt)
  end
  -- run all collected callbacks, having adjusted queue
  local k, cbs, v
  for k,cbs in ipairs(cbt) do for k,v in ipairs(cbs) do v() end end
end
local function queue(self,when,what,...)
  local entryt = self:now()
  local lapsed = (entryt > self._tst) and (entryt - self._tst)/1000 or 0
  self._tst = entryt
   -- scan upwards for insertion position
  local ix = 0
  local tleft = when
  while ix < #self._q do
    local qi = self._q[ix+1]
    -- credit lapsed time, if any
    if     (lapsed > qi.t) then lapsed = lapsed - qi.t ; qi.t = 0 -- entirely covers
    elseif (lapsed > 0   ) then qi.t = qi.t - lapsed ; lapsed = 0 -- partially covers
    end
    -- see if this bucket extends far enough in time
    -- (now that we have subtracted any lapsed time)
    if (tleft < qi.t) then break end
    ix = ix + 1; tleft = tleft - self._q[ix].t
  end
  -- invariant: lapsed == 0
  -- create queue element
  local warg = {...}; local nwarg = select('#',...)
  local wfn = function () what(unpack(warg,1,nwarg)) end
  if ix == 0 then
    -- we're going at the head of the queue, so set the new firing time
    self:arm(when, entryt)
  elseif tleft == 0 then
    -- we're going in an existing bucket that isn't the first
    table.insert(self._q[ix],wfn)
    return wfn
  end
  -- create a new bucket
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
local function defl_arm(self,t)
  self.tmr:alarm(t, tmr.ALARM_SINGLE, function() self:fire() end)
end
return function(tmrix) return {
  _q = {}, _tst = 0,
  ["fire"] = fire, ["arm"] = defl_arm, ["now"] = tmr and tmr.now,
  ["tmr"] = tmrix, ["queue"] = queue, ["dequeue"] = dequeue
} end
