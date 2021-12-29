-- SOFT DEPENDS: file, rtcfifo, node, wifi
local k,v
if node then
  local function info(t) print('INFO', t) for k,v in pairs(node.info(t)) do print("", k, v) end end
  info('hw')
  info('sw_version')
  info('build_config')
  print('HEAP', node.heap())
end
if wifi then
  print('WIFI',wifi.getmode(),wifi.sta.getmac(), wifi.ap.getmac())
  print('HOST',wifi.sta.gethostname())
  print('WAP',wifi.ap.getconfig())
  print('WSTA',wifi.sta.getconfig())
  do
    local x=wifi.sta.getapinfo()
    local y=wifi.sta.getapindex()
    for i=1,x.qty do
      print(string.format("\t%s%-6d %-32s %-64s %-18s",
        i == y and "*" or " ", i,
        x[i].ssid, x[i].pwd or "-", x[i].bssid or "-"))
    end
  end
  print('IP',wifi.sta.getip(), wifi.ap.getip())
end
if rtcfifo then
  print('RTCF', rtcfifo.ready() ~= 0 and rtcfifo.count() or "NOT PREPARED")
end
if file then
  print('FS', ("rem=%d used=%d sz=%d"):format(file.fsinfo()))
    for k,v in pairs(file.list()) do print("",k,v) end
end
if node then
 local i = node.info('lfs')
 if ba then
   print('LFS',("baseaddr=0x%x sz=0x%x used=0x%x mapaddr=0x%x"):
     format(i.lfs_base, i.lfs_size, i.lfs_used, i.lfs_mapped))
   for k,v in ipairs(t) do print("", v) end
 else
   print('LFS',"Not installed")
 end
end
print('PACKAGES')
  for k,v in pairs(package.loaded) do print("",k,v) end
print('GLOBAL')
  for k,v in pairs(_G) do print("",k,v) end
