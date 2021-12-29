local preload = "?.lc;?.lua", "/\n;\n?\n!\n-\n", "@init.lua",
"=stdin", "stdin", "stdout", "Lua 5.1", "Lua 5.3", "LUABOX",
"(for index)", "(for limit)", "(for step)", "__pairs",
--
"searchers", "searchpath",
"_G", "_LOADED", "_LOADLIB", "_PRELOAD", "_VERSION", "_PROMPT",
"__add", "__call", "__concat", "__div", "__eq", "__gc", "__index", "__le",
"__len", "__lt", "__mod", "__mode", "__mul", "__name", "__newindex", "__pow",
"__sub", "__tostring", "__unm",
--
"collectgarbage", "cpath", "debug", "file", "file.obj",
"file.vol", "flash", "getstrings", "index", "ipairs", "list", "loaded",
"loader", "loaders", "loadlib", "module", "net.tcpserver", "net.tcpsocket",
"net.udpsocket", "newproxy", "onerror", "package", "pairs", "path", "preload",
"reload", "require", "seeall", "sntppkt.resp", "wdclr", "not enough memory",
"sjson.decoder","sjson.encoder", "tmr.timer"

local initload =
  ".lc", ".lua", "loadfile",
  "Module not in LFS", 
  "NODE-%06X RECOVERY (auto reboot cancelled)", 
  "Overlay is a synthetic view! "
