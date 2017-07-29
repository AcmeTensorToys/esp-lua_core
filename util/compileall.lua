-- find all /.*\.lua/ files except "init.lua" and compile them.
local k,v
for k,v in pairs(file.list()) do
  local ix, _ = k:find("^.*%.lua$")
  if ix and k ~= "init.lua" then
    node.compile(k); file.remove(k)
  end
end
