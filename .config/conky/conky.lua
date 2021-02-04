------------------------------------------------------------------------------------------------
-- GLOBALS
------------------------------------------------------------------------------------------------
-- table to hold static system information and the conky query string
static_info = {}
static_info.roomtemp = 25   --ambient (room) temperature in degrees C
static_info.hightemp = 100  --maximum temperature for temp graph
static_info.ntopcpu = 10    --show top n number of process info desending cpu load
static_info.ntopmem = 10    --show top n number of process info desending mem load
static_info.cquery = ''     --initialize to suppress initial conky_update 'expecting a string' warning

-- dynamic system information
dynamic_info = {}
-- query_array will be used to populate dynamic_info table and to make the query to conky
-- query conky only once per update to avoid syncing issues
query_array = {}

------------------------------------------------------------------------------------------------
-- DEFINE HELPER FUNCTIONS
------------------------------------------------------------------------------------------------

function add_query (query, init)
    dynamic_info[query] = init
    query_array[#query_array + 1] = query
    return nil
end

string.rpad = function(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function concat (...)
    return table.concat({...}, '')
end

function map(func, array)
    local new_array = {}
    for i,v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end

function get_rgb_tuple (rgb)
    local arr = {rgb:sub(1,2), rgb:sub(3,4), rgb:sub(5,6)}
    local func = function(x) return tonumber(x, 16) end
    return map(func, arr)
end

function round(x) return math.floor(x + 0.5) end

------------------------------------------------------------------------------------------------
-- LUA_STARTUP_HOOK FUNCTION
------------------------------------------------------------------------------------------------

function conky_startup ()
    static_info.ncpus = 8     --TODO: make this more general
    
    static_info.rantemp = static_info.hightemp - static_info.roomtemp

    -- get CPU info
    local f = assert(io.popen('lscpu'))
    local x = assert(f:read('*a'))
    static_info.cpuminfreq = tonumber(string.match(x, "CPU min MHz:%s+(%d+%.%d+)"))/1000
    f:close()

    --get path containing temperature sensor info
    local temp_prefix = '/sys/devices/platform/'
    local f = assert(io.popen(concat('find ', temp_prefix, 'coretemp.0/hwmon/hwmon? -maxdepth 0')))
    static_info.temppath = assert(f:read('*a')):sub(23,-2) -- cut off the '/sys/devices/platform/' part
    f:close()

    --get number of temperature sensors
    local f = assert(io.popen(concat('find ', temp_prefix, static_info.temppath, '/temp?_label -maxdepth 0 | wc -l')))
    static_info.ntemps = tonumber(assert(f:read('*a')):sub(1,-2))
    f:close()

    --determine NV-CONTROL X extension is present
    if (conky_parse("${nvidia gpufreqmin}") == '') then
        static_info.nvidia = false
    else
        -- if it returns anything then assume it is present
        static_info.nvidia = true
    end

    if static_info.nvidia then
        static_info.nvidia_gpufreqmin = conky_parse("${nvidia gpufreqmin}")
        static_info.nvidia_memfreqmin = conky_parse("${nvidia memfreqmin}")

        add_query('nvidia gpuutil', 0)
        add_query('nvidia memutil', 0)
        add_query('nvidia gputemp', static_info.roomtemp)
        add_query('nvidia gpufreqcur', static_info.nvidia_gpufreqmin)
        add_query('nvidia memfreqcur', static_info.nvidia_memfreqmin)
    end

    for i = 0,static_info.ncpus do
        add_query('cpu cpu' .. i, 0)
        add_query('freq_g ' .. i, static_info.cpuminfreq)
    end

    local temp_label_len = 0
    for i = 1,static_info.ntemps do
        local k = 'temp ' .. i
        add_query(table.concat({'platform', static_info.temppath, k}, ' '), static_info.roomtemp)
    end

    for i = 1,static_info.ntopcpu do
        add_query('top name ' .. i, '')
        add_query('top pid ' .. i, '')
        add_query('top cpu ' .. i, 0)
        add_query('top mem ' .. i, 0)
    end

    for i = 1,static_info.ntopmem do
        add_query('top_mem name ' .. i, '')
        add_query('top_mem pid ' .. i, '')
        add_query('top_mem cpu ' .. i, 0)
        add_query('top_mem mem ' .. i, 0)
    end

    add_query('mem', '        ')
    add_query('memperc', 0)

    add_query('swap', '')
    add_query('swapperc', 0)

    add_query('fs_used /', '        ')
    add_query('fs_used_perc /', 0)

    static_info.cquery = '${' .. table.concat(query_array, '}\n${') .. '}'

    static_info.memmax = conky_parse('${memmax}')
    static_info.swapmax = conky_parse('${swapmax}')
    static_info.rootsize = conky_parse('${fs_size /}')

    return ''
end

------------------------------------------------------------------------------------------------
-- LUA_DRAW_HOOK_PRE FUNCTION
------------------------------------------------------------------------------------------------

function conky_update ()
    local info = conky_parse(static_info.cquery)
    local i = 0
    for val in string.gmatch(info, '[^\n]+') do
        i = i + 1
        dynamic_info[query_array[i]] = val
    end
    return ''
end

------------------------------------------------------------------------------------------------
-- CONKY FUNCTIONS
------------------------------------------------------------------------------------------------

function conky_cpu_name ()
    local f = assert(io.popen('lscpu | sed -nr \'/Model name/ s/.*:\\s*(.*) @ .*/\\1/p\''))
    local name = assert(f:read('*a')):sub(1, -2) -- remove newline
    f:close()
    return name
end

function conky_var (s)
    return dynamic_info[s]
end

-- unable to escape spaces in calls like ${lua_graph 'numvar cpu 1'} and conky interprets it as 
-- two arguments
function conky_numvar (...)
    return tonumber(dynamic_info[table.concat({...}, ' ')]) or 0
end

function conky_zero() return 0 end

function conky_numvar_color (...) return conky_color(conky_numvar(...)) end

function conky_cpu (i)
    return concat(
        'CPU',
        i,
        '  ',
        string.format('%4.2f', dynamic_info['freq_g ' .. i]),
        ' GHz  ',
        string.format('%3i', dynamic_info['cpu cpu' .. i]),
        '%'
    )
end

function conky_tempval (i)
    local x = dynamic_info[table.concat({'platform', static_info.temppath, 'temp', i}, ' ')]
    return (x  - static_info.roomtemp)*100/static_info.rantemp
end

function conky_temp (i)
    return dynamic_info[concat('platform ', static_info.temppath, ' temp ', i)]
end

function conky_nvidia ()
    if static_info.nvidia then
        return '"true"'
    else
        return '"false"'
    end
end


function conky_nvidia_temp ()
    return concat(
        'GPU @ ',
        dynamic_info['nvidia gputemp'],
        '°C'
    )
end

function conky_nvidia_gpu ()
    return concat(
        'GPU @ ',
        dynamic_info['nvidia gpufreqcur'],
        ' MHz ',
        dynamic_info['nvidia gpuutil'],
        '%'
    )
end

function conky_nvidia_mem ()
    return concat(
        'MEM @ ',
        dynamic_info['nvidia memfreqcur'],
        ' MHz ',
        dynamic_info['nvidia memutil'],
        '%'
    )
end

function conky_top_cpu (i)
    return concat(
        dynamic_info['top name ' .. i],
        dynamic_info['top pid ' .. i],
        string.format('%7.2f', dynamic_info['top cpu ' .. i]),
        string.format('%7.2f', dynamic_info['top mem ' .. i])
    )
end

function conky_top_mem (i)
    return concat(
        dynamic_info['top_mem name ' .. i],
        dynamic_info['top_mem pid ' .. i],
        string.format('%7.2f', dynamic_info['top_mem cpu ' .. i]),
        string.format('%7.2f', dynamic_info['top_mem mem ' .. i])
    )
end

function conky_mem ()
    return concat(
        string.format('%-8s', 'RAM'),
        string.format('%8s', dynamic_info['mem']),
        ' / ',
        static_info.memmax
    )
end

function conky_swap ()
    local perc = dynamic_info['swapperc']
    return concat(
        string.format('%-8s', 'SWAP'),
        string.format('%8s', dynamic_info['swap']),
        ' / ',
        static_info.swapmax
    )
end

function conky_root ()
    return concat(
        string.format('%-8s', '/'),
        dynamic_info['fs_used /'],
        ' / ',
        static_info.rootsize
    )
end
