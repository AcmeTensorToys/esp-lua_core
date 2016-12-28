-- utilities for handling morse code
local malpha =
 { [48] = '33333' -- 0
 , [49] = '13333'
 , [50] = '11333'
 , [51] = '11133'
 , [52] = '11113'
 , [53] = '11111'
 , [54] = '31111'
 , [55] = '33111'
 , [56] = '33311'
 , [57] = '33331' -- 9
 , [97] = '13' -- a
 , [98] = '3111'
 , [99] = '3131'
 , [100] = '311'
 , [101] = '1'
 , [102] = '1131'
 , [103] = '331'
 , [104] = '1111'
 , [105] = '11'
 , [106] = '1333' -- j
 , [107] = '313'
 , [108] = '1311'
 , [109] = '33'
 , [110] = '31'
 , [111] = '333'
 , [112] = '1331'
 , [113] = '3313'
 , [114] = '131'
 , [115] = '111'
 , [116] = '3' -- t
 , [117] = '113'
 , [118] = '1113'
 , [119] = '133'
 , [120] = '3113'
 , [121] = '3133'
 , [122] = '3311' -- z
 }

return function (istr)
  local function fail() return nil end
  local strix = 0 -- last character of istr moved to cstr
  local chix = 0 -- last position of ch shifted out
  local on = false
  local cstr

  local function nextcstr()
    cstr = nil; chix = 0;
    if strix < istr:len() then
      strix = strix + 1 
      local b = istr:sub(strix,strix):lower():byte(1)
      cstr = malpha[b] or '666'
    end
  end

  local function nextt()
    if on then
     on = false
     if chix  < cstr:len() then return 1, false end
     nextcstr()
     return (cstr and 3), false
    elseif chix < cstr:len() then
      chix = chix + 1
      local c = cstr:sub(chix,chix)
      if c == ' ' then return 7, false end
      on = true
      return tonumber(cstr:sub(chix,chix)), true
    else return nil
    end
  end

  nextcstr() -- prime pump

  -- cb takes: on/off, duration in dits (1,3,7)
  return function(cb)
    local t,p = nextt()
    if t then cb(t,p); return true else return false end
  end
end
