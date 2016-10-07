-- DEPENDS: file, rtcfifo, node, wifi
print('INFO:',string.format("major=%d minor=%d dev=%d chip=%d flash=%d fs=%d fm=%d fs=%d",node.info()))
print('HEAP:', node.heap())
print('WIFI:',wifi.getmode())
print('MAC:',wifi.sta.getmac(), wifi.ap.getmac())
print('HOST:',wifi.sta.gethostname())
print('WSTA:',wifi.sta.getconfig())
print('WAP:',wifi.ap.getconfig())
print('IP:',wifi.sta.getip(), wifi.ap.getip())
if rtcfifo.ready() ~= 0 then print('RTCF:',rtcfifo.count()) else print('RTCF:','NOT PREPARED') end
print('FS:', file.fsinfo()); for k,v in pairs(file.list()) do print("",k,v) end
print('GLOBAL:'); for k,v in pairs(_G) do print("",k,v) end
