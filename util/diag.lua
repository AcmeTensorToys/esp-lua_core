-- SOFT DEPENDS: file, rtcfifo, node, wifi
local k,v
if node then
  print('INFO', 'hw') for k,v in pairs(node.info('hw')) do print("", k, v) end
  print('INFO', 'sw_version') for k,v in pairs(node.info('sw_version')) do print("", k, v) end
  print('INFO', 'build_config') for k,v in pairs(node.info('build_config')) do print("", k, v) end
  print('HEAP', node.heap())
end
if wifi then
  print('WIFI',wifi.getmode())
  print('MAC',wifi.sta.getmac(), wifi.ap.getmac())
  print('HOST',wifi.sta.gethostname())
  print('WSTA',wifi.sta.getconfig())
  print('WAP',wifi.ap.getconfig())
  print('IP',wifi.sta.getip(), wifi.ap.getip())
end
if rtcfifo then
  if rtcfifo.ready() ~= 0 then print('RTCF',rtcfifo.count()) else print('RTCF','NOT PREPARED') end
end
if file then
  print('FS', file.fsinfo()); for k,v in pairs(file.list()) do print("",k,v) end
end
if node.flashindex then
 local ut, fa, ma, sz, t = node.flashindex()
 if ut then
   print('LFS', ut, fa, ma, sz)
   for k,v in ipairs(t) do print("", v) end
 else
   print('LFS', fa, ma)
 end
end
print('PACKAGES'); for k,v in pairs(package.loaded) do print("",k,v) end
print('GLOBAL'); for k,v in pairs(_G) do print("",k,v) end
