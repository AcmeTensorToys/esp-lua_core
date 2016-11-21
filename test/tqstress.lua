t = dofile("tq/tq.lua")()

tdiag = dofile("tq/tq-diag.lua")
function td()
  tdiag(t,
    function(...) print("td set",...) end,
    function(...) print("td elem",...) end)
end

ttime    = 0
tfirearm = nil
tfirewhen = nil
t.arm = function(_,fire,when) tfirearm = fire ; tfirewhen = when end
t.now = function(_) return ttime end
function tfire(step)
  ttime = ttime + step*1000
  if tfirearm then tfa = tfirearm; tfirearm = nil; tfa() end
end

ctr = 0
function rec()
  ctr = ctr + 1; t:queue(math.random(5),rec)
end
rec()

for i = 1, 100000 do tfire(tfirewhen or 1) end
print(ctr, ttime)
td()
