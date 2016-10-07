-- call directly or wrap in tq immediately to get updated leader time value:
-- tq:queue(1,function() dofile("tq-diag.lc")(tq,print,print) end)
return function (self,kt,ke) local i,t; for i,t in ipairs(self._q) do kt(i,t["t"],#t) for k,v in ipairs(t) do ke(i,k,v) end end end
