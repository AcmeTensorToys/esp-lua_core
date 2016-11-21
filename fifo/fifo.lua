-- Remove an element and pass it to k; if that returns a function, leave that
-- pending at the top of the fifo.  Thus, we can get events that do multiple
-- things.  If the queue is empty, do not invoke k but flag it to enable
-- immediate execution at the next call to queue.
--
-- Returns 'true' if the queue was not empty, 'false' otherwise.
local function dequeue(q,k)
  if #q > 0
   then local new = k(q[1]) ; if new == nil then table.remove(q,1) else q[1] = new end ; return true
   else q._go = true ; return false
  end
end
-- Queue a on queue q.
--
-- If k is provided and the queue has previously drained, dequeue immediately
-- as if k had passed to dequeue.  This is useful when k will arrange for
-- subsequent dequeues.
local function queue(q,a,k)
  table.insert(q,a)
  if k ~= nil and q._go then q._go = false; q:dequeue(k) end
end
-- return a FIFO constructor
return function()
  return { ['_go'] = true ; ['queue'] = queue ; ['dequeue'] = dequeue }
end
