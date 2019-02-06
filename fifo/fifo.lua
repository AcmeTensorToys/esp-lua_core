-- Remove an element and pass it to k; if that returns a value, leave that
-- pending at the top of the fifo.  Thus, we can get events that do multiple
-- things.
--
-- If k returns nil, the fifo will be advanced.  Moreover, k may return a
-- second result, a boolean, which indicates whether or not this dequeue
-- "counts" as one; this is useful for "phantom" elements in the fifo, such as
-- (placeholders for) callbacks to observers, that cannot otherwise act as
-- ordinary fifo elements do.
--
-- If the queue is empty, do not invoke k but flag it to enable immediate
-- execution at the next call to queue.
--
-- Returns 'true' if the queue contained at least one non-phantom entry,
-- 'false' otherwise.
local function dequeue(q,k)
  if #q > 0
   then
     local new, again = k(q[1])
     if new == nil
       then table.remove(q,1)
            if again then return dequeue(q, k) end -- note tail call
       else q[1] = new
     end
     return true
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
  if k ~= nil and q._go then q._go = false; dequeue(q, k) end
end
-- return a FIFO constructor
return function()
  return { ['_go'] = true ; ['queue'] = queue ; ['dequeue'] = dequeue }
end
