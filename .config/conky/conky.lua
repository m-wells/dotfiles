--function conky_green2red(x)
--    if type(x) == "string" then
--        return conky_green2red(tonumber(conky_parse(x)))
--    end
--    if x > 75 then
--        return "${color red}"
--    end
--    if x > 50 then
--        return "${color orange}"
--    end
--    if x > 25 then
--        return "${color yellow}"
--    end
--    return "${color green}"
--end
--
--function conky_red2green(x)
--    if type(x) == "string" then
--        return conky_red2green(tonumber(conky_parse(x)))
--    end
--    r = string.format("%02x", math.floor(255*(1-x/100)))
--    g = string.format("%02x", math.floor(255*x/100))
--    return "${color "..r..g.."00}"
--end
--
--function conky_temp(n)
--    return tonumber(conky_parse("${platform coretemp.0/hwmon/hwmon4 temp " .. n .. "}"))
--end
--
--function conky_tempcolor(n)
--    t = conky_temp(n)
--    return conky_green2red(t)..tostring(t).."°C"..
--           "${lua_bar 10,420 noop "..t.."}${color}\n"
--end
--
--function conky_temperature(i,j)
--    ti = conky_temp(i)
--    tj = conky_temp(j)
--    ci = conky_green2red(ti)
--    cj = conky_green2red(tj)
--    si = tostring(ti)
--    sj = tostring(tj)
--
--    return "${goto  80}"..ci..si.."°C"..
--           "${goto 405}"..cj..sj.."°C".."\n"..
--           ci.."${lua_bar noop "..si.."}${goto 325}"..
--           cj.."${lua_bar noop "..sj.."}${color}"
--end
--
function conky_ppad(p,n)
    return string.format("%"..tostring(p).."d", tonumber(conky_parse(n))).."%"
end

function conky_pad7(n)
    return string.format("%7d", tonumber(conky_parse(n)))
end
--
--function conky_ppad_green2red(n)
--    return conky_green2red(n)..conky_ppad(n)
--end
--
--function conky_ppad_red2green(n)
--    return conky_red2green(n)..conky_ppad(n)
--end
--
--function conky_luaswap()
--    return tonumber(conky_parse("${swapperc}"))
--end
--
--function conky_filesystem(f)
--    t = tonumber(conky_parse("${fs_used_perc "..f.."}"))
--    return conky_green2red(t)
--end
