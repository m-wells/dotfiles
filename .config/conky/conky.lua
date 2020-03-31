function conky_green2red(x)
    if type(x) == "string" then
        return conky_green2red(tonumber(conky_parse(x)))
    end
    r = string.format("%02x", math.floor(255*x/100))
    g = string.format("%02x", math.floor(255*(1-x/100)))
    return "${color "..r..g.."00}"
end

function conky_red2green(x)
    if type(x) == "string" then
        return conky_red2green(tonumber(conky_parse(x)))
    end
    r = string.format("%02x", math.floor(255*(1-x/100)))
    g = string.format("%02x", math.floor(255*x/100))
    return "${color "..r..g.."00}"
end

function conky_temp(n)
    return tonumber(conky_parse("${platform coretemp.0/hwmon/hwmon4 temp " .. n .. "}"))
end

function conky_temperature(n)
    t = conky_temp(n)
    return conky_green2red(t)..tostring(t).."C"
end

function conky_ppad(n)
    return string.format("%3d", tonumber(conky_parse(n))).."%"
end

function conky_ppad_green2red(n)
    return conky_green2red(n)..conky_ppad(n)
end

function conky_ppad_red2green(n)
    return conky_red2green(n)..conky_ppad(n)
end

function conky_luaswap()
    return tonumber(conky_parse("${swapperc}"))
end

function conky_filesystem(f)
    t = tonumber(conky_parse("${fs_used_perc "..f.."}"))
    return conky_green2red(t)
end
