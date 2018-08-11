morse = dofile("morse/morse.lua")

function tm(str)
  local m = morse(str)
  while m(print) do end
end
