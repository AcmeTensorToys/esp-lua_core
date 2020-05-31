-- DEPENDS: node, rtcfifo?
return {
  ["boot"] = function(_,s) s(string.format("raw=%d reason=%d",node.bootreason())) end,
  ["hwinfo"] = function(_,s)
    local ni = node.info('hw')
    s(("chipid=%d flashsize=%d"):format(ni.chip_id,ni.flash_size))
  end,
  ["swinfo"] = function(_,s)
    local nis = node.info('sw_version')
    local nic = node.info('build_config')
    s(("git=%s ssl=%s num=%s modules=%s"):format(
      nis.git_commit_id,
      tostring(nic.ssl),
      nic.number_type,
      nic.modules))
  end,
  ["heap"] = function(_,s) s(string.format("free=%d",node.heap())) end,
  ["fifo"] = function(_,s) if rtcfifo and rtcfifo.ready() ~= 0 then s(string.format("fifo=%d",rtcfifo.count())) else s("no rtcfifo") end end,
	-- restart in some ticks, so that network callbacks have a chance to fire
	-- first, or else we might crash.  Ick!
  --
  -- Apparently we need "some" because the pipe and socket sometimes take one to do its
  -- uncorking and the network stack is its own monstrosity.  Either way, probably fine.
  ["restart"] = function(_,s) tmr.create():alarm(10, tmr.ALARM_SINGLE, node.restart) end,
  ["exec"] = function(l,s)
	local f, err = loadstring(l)
	if f
     then getfenv(f).send = function(x) s(tostring(x)) end
          local ok, res = pcall(f); if ok then s("ok: "..tostring(res)) else s("pcall err: "..res) end
     else s("err: "..err)
    end
   end
}
