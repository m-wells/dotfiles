do
    local config = ...

    local temppath = conky_parse(
        "${exec \"find /sys/devices/platform/coretemp.0/hwmon/hwmon? -maxdepth 0\"}"
    )
    --patern for termperature label (%d will be replaced by a number)
    config.temp_label = "${cat "..temppath.."/temp%d_label}"
    --patern for termperature query (%d will be replaced by a number)
    config.temp_query = "exec \"cat "..temppath.."/temp%d_input | rev | cut -c4- | rev\""

    ------------------------------------------------------------------------------------------------
    --Initialize
    ------------------------------------------------------------------------------------------------
    local tempfactor = 100/(config.hightemp - config.roomtemp)
    local temps = {}
    temps.str = {}
    temps.scl = {}
    local memmax        --maximum size of ram
    local swapmax       --maximum size of swap
    local rootsize      --maximum size of /
    local homesize      --maximum size of /home
    local header        --table header
    local column        --table separators
    local footer        --table footer
    local cquery        --table that holds the string to send to conky and the hashes to obtain the
                        --    returned values
    local strvars = {}
    local numvars = {}
    if conkystring == nil then
        cquery = {}
        cquery.hashes = {}
        cquery.numhashes = {}
    
        --str: the conky variable call (without "${" and "}")
        --getnumber: boolean indicating if this variable will be used numerically (for graphs or
        --  to get colors)
        local function cstrings (str, getnumber)
            table.insert(cquery.hashes, str)
            if getnumber then
                table.insert(cquery.numhashes, str)
            end
        end
        --strvars = {}
        --local chashes = {}  --hashes to use for strvars
        --local nhashes = {}  --hashes to use for numvars
    
        --nvar: a boolean indicating that the numerical value will also be needed in addition to the
        --  raw string returned from conky)
        --min and max: if nvar is true, the value will be mapped from [min,max] to [0,100]
        --local function cstrings (str, nvar, min, max)
        --    table.insert(cstrs, "${")
        --    table.insert(cstrs, str)
        --    table.insert(cstrs, "}\n")
        --    table.insert(chashes, str)
        --    if nvar == true then
        --        if min == nil then min = 0 end
        --        if max == nil then max = 100 end
        --        nhashes[str] = {min, max}
        --    end
        --end
        ------------------------------------------------------------------------------------------------
        for i = 1, config.ncpus do
            local s = tostring(i)
            cstrings("freq_g "..s)
            cstrings("cpu cpu"..s, true)
        end
        ------------------------------------------------------------------------------------------------
        templabels = {}
        for i = 1, config.ntemps do
            local s = tostring(i)
            templabels[s] = conky_parse(string.format(config.temp_label, i))
            cstrings(string.format(config.temp_query, i), true)
        end
        ------------------------------------------------------------------------------------------------
        memmax = conky_parse("${memmax}"):gsub("%s", "")
        cstrings("memperc", true)
        cstrings("mem")
        swapmax = conky_parse("${swapmax}"):gsub("%s", "")
        cstrings("swapperc", true)
        cstrings("swap")
        ------------------------------------------------------------------------------------------------
        rootsize = conky_parse("${fs_size /}"):gsub("%s", "")
        cstrings("fs_used_perc /", true)
        cstrings("fs_used /")
        homesize = conky_parse("${fs_size /home}"):gsub("%s", "")
        cstrings("fs_used_perc /home", true)
        cstrings("fs_used /home")
        ------------------------------------------------------------------------------------------------
        --header = "${alignc}${color}"..
        header = "${color}"..
                 "┌"..string.rep("─",19)..
                 "┬"..string.rep("─",8)..
                 "┬"..string.rep("─",7)..
                 "┬"..string.rep("─",7)..
                 "┐\n"..
                 "│"..string.format("%-19.19s","Name")..
                 "│"..string.format("%8.8s","PID")..
                 "│"..string.format("%7.7s","CPU")..
                 "│"..string.format("%7.7s","MEM")..
                 "│\n"..
                 "├"..string.rep("─",19)..
                 "┼"..string.rep("─",8)..
                 "┼"..string.rep("─",7)..
                 "┼"..string.rep("─",7)..
                 "┤"
        column = "${color}"..
                 "│"..string.rep(" ",19)..
                 "│"..string.rep(" ",8)..
                 "│"..string.rep(" ",7)..
                 "│"..string.rep(" ",7)..
                 "│"
        footer = "${color}"..
                 "└"..string.rep("─",19)..
                 "┴"..string.rep("─",8)..
                 "┴"..string.rep("─",7)..
                 "┴"..string.rep("─",7)..
                 "┘"
        for i = 1, config.ntopcpu do
            local s = tostring(i)
            cstrings("top name "..s)
            cstrings("top pid "..s)
            cstrings("top cpu "..s, true)
            cstrings("top mem "..s)
        end
        for i = 1, config.ntopmem do
            local s = tostring(i)
            cstrings("top_mem name "..s)
            cstrings("top_mem pid "..s)
            cstrings("top_mem cpu "..s)
            cstrings("top_mem mem "..s, true)
        end
        --------------------------------------------------------------------------------------------
        cquery.qstr = "${"..table.concat(cquery.hashes, "}\n${").."}\n"
    end
    ------------------------------------------------------------------------------------------------
    --
    ------------------------------------------------------------------------------------------------
    function conky_update ()
        local info = conky_parse(cquery.qstr)
        local i = 0
        for var in string.gmatch(info, "[^\n]+") do
            i = i + 1
            strvars[cquery.hashes[i]] = var:gsub("%s", "")
        end
        for _,hash in ipairs(cquery.numhashes) do
            numvars[hash] = tonumber(strvars[hash])
        end
        for j = 1, config.ntemps do
            local jstr = tostring(j)
            local x = string.format(config.temp_query, j)
            temps.str[jstr] = strvars[x]
            temps.scl[jstr] = (numvars[x] - config.roomtemp)*tempfactor
        end
        return ""
    end
    ------------------------------------------------------------------------------------------------
    --
    ------------------------------------------------------------------------------------------------
    function conky_strvars (...) return strvars[table.concat(table.pack(...), " ")] end
    function conky_numvars (...) return numvars[table.concat(table.pack(...), " ")] end
    function conky_tempscl (i) return temps.scl[i] end
    function conky_zero () return 0 end
    ------------------------------------------------------------------------------------------------
    --
    ------------------------------------------------------------------------------------------------
    function conky_color(x)
        if type(x) == "string" then
            return conky_color(tonumber(x))
        end
        if x > 75 then
            return "${color dc322f}"
        end
        if x > 50 then
            return "${color cb4b16}"
        end
        if x > 25 then
            return "${color b58900}"
        end
        return "${color 859900}"
    end
    ------------------------------------------------------------------------------------------------
    --
    ------------------------------------------------------------------------------------------------
    function conky_cpu (i)
        local x = numvars["cpu cpu"..i]
        return "${color}"..
               "CPU"..
               i..
               ":${alignr}"..
               conky_color(x)..
               strvars["freq_g "..i]..
               "GHz  "..
               string.format("%3.1d%%", x)..
               "${color}"
    end
    ------------------------------------------------------------------------------------------------
    --
    ------------------------------------------------------------------------------------------------
    function conky_temp(s)
        return "${color}"..
               templabels[s]..
               ":${alignr}"..
               conky_color(temps.scl[s])..
               temps.str[s]..
               "°C${color}"
    end
    
    --function conky_ramperc () return memory.memperc_str end
    --function conky_swpperc () return memory.swpperc_str end
    
    function conky_mem ()
        return "${color}"..
               "RAM:${alignr}"..
               conky_color(numvars["memperc"])..
               strvars["mem"]..
               "/"..
               memmax..
               "${color}"
    end
    
    function conky_swap ()
        return "${color}"..
               "Swap:${alignr}"..
               conky_color(numvars["swapperc"])..
               strvars["swap"]..
               "/"..
               swapmax..
               "${color}"
    end
    
    function conky_rootperc () return numvars["fs_used_perc /"] end
    function conky_homeperc () return numvars["fs_used_perc /home"] end

    function conky_rootcolor () return conky_color(conky_rootperc()) end
    function conky_homecolor () return conky_color(conky_homeperc()) end
    
    function conky_root ()
        return "${color}"..
               "/${alignr}"..
               conky_rootcolor()..
               strvars["fs_used /"]..
               "/"..
               rootsize..
               "${color}"
    end
    
    function conky_home ()
        return "${color}"..
               "/home${alignr}"..
               conky_homecolor()..
               strvars["fs_used /home"]..
               "/"..
               homesize..
               "${color}"
    end
    
    
    function conky_header () return header end
    function conky_column () return column end
    function conky_footer () return footer end
    
    function conky_top(i)
        local s = tostring(i)
        return conky_color(numvars["top cpu "..s])..
               " "..string.format("%-19.19s", strvars["top name "..s])..
               " "..string.format("%8.8s", strvars["top pid "..s])..
               " "..string.format("%6.6s", strvars["top cpu "..s])..
               "% "..string.format("%6.6s", strvars["top mem "..s])..
               "% "
    end
    
    function conky_top_mem(i)
        local s = tostring(i)
        return conky_color(numvars["top_mem mem "..s])..
               " "..string.format("%-19.19s", strvars["top_mem name "..s])..
               " "..string.format("%8.8s", strvars["top_mem pid "..s])..
               " "..string.format("%6.6s", strvars["top_mem cpu "..s])..
               "% "..string.format("%6.6s", strvars["top_mem mem "..s])..
               "% "
    end
    
    
    --function conky_mem_proc(n)
    --    local i = tonumber(n)
    --    return conky_color(proc.mem[i])..
    --           " "..proc.mem_name[i]..
    --           " "..proc.mem_pid[i]..
    --           " "..proc.mem_cpu[i]..
    --           "% "..proc.mem_mem[i]..
    --           "%"
    --end
end
