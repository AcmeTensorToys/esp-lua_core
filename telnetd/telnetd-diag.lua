-- DEPENDS: node, rtcfifo?
return {
  ["boot"] = function(_,s) s(string.format("raw=%d reason=%d",node.bootreason())) end,
  ["info"] = function(_,s) s(string.format("major=%d minor=%d dev=%d chip=%d flash=%d fs=%d fm=%d fs=%d",node.info())) end,
  ["heap"] = function(_,s) s(string.format("free=%d",node.heap())) end,
  ["fifo"] = function(_,s) if rctfifo and rtcfifo.ready() ~= 0 then s(string.format("fifo=%d",rtcfifo.count())) else s("no rtcfifo") end end,
  ["exec"] = function(l,s)
	local f, err = loadstring(l)
	if f then local ok, res = pcall(f); if ok == true then s("ok: "..tostring(res)) else s("pcall err: "..res) end
         else s("err: "..err) end end
}
