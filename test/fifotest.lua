fmk = dofile("util/fifo.lua")
tmk = dofile("tq/tq.lua")
tdiag = loadfile("tq/tq-diag.lua")()

f = fmk()
t = tmk()

ttime    = 0
tfirearm = nil
t.arm = function(_,fire,when) tfirearm = fire; print("t arm: ", when) end
t.now = function(_) return ttime end
function tfire(step)
  ttime = ttime + step*1000
  if tfirearm
   then print("t fire"); tfa = tfirearm; tfirearm = nil; tfa()
   else print("t fizzle")
  end
end

function tqp(w,s) t:queue(w,print,s) end
function td()
  tdiag(t,
    function(...) print("td set",...) end,
    function(...) print("td elem",...) end)
end

function deq(n)
  if f:dequeue(function(e) print("deq", e) ; return n end)
   then print("deq enqueue"); t:queue(1000,deq,nil)
  end
end

f:queue(1)
f:queue(2)
f:queue(3)
f:queue(4)

print("SETUP")
t:queue(1000,deq,5)
t:queue(1500,deq,6)
t:queue(2000,deq,7)
td()
print()

print("PREMATURE FIRE")
tfire(50)
td()
print()

print("POSTMATURE FIRE")
tfire(1000)
td()
print()

print("EXACT FIRE 1")
tfire(450)
td()
print()

print("EXACT FIRE 2")
tfire(500)
td()
print()

tfire(50)
print()

tfire(450)
print()

tfire(500)
print()

tfire(50)
print()

tfire(450)
print()

tfire(600)
print()

td()
print()
