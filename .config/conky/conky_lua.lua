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
--function nvidia_load ()
--    local f = assert(io.popen('nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits'))
--    local load_perc = assert(f:read('*a')):sub(1, -2) -- remove newline
--    f:close()
--    return load_perc
--end
------------------------------------------------------------------------------------------------
-- LUA_STARTUP_HOOK FUNCTION
------------------------------------------------------------------------------------------------
function conky_startup ()
    static_info.ncpus = 8     --TODO: make this more general

    --get path containing temperature sensor info
    local temp_prefix = '/sys/devices/platform/'
    local f = assert(io.popen(concat('find ', temp_prefix, 'coretemp.0/hwmon/hwmon? -maxdepth 0')))
    static_info.temppath = assert(f:read('*a')):sub(23,-2) -- cut off the '/sys/devices/platform/' part
    f:close()
    
    static_info.rantemp = static_info.hightemp - static_info.roomtemp

    --get number of temperature sensors
    local f = assert(io.popen(concat('find ', temp_prefix, static_info.temppath, '/temp?_label -maxdepth 0 | wc -l')))
    static_info.ntemps = tonumber(assert(f:read('*a')):sub(1,-2))
    f:close()

    --determine if system uses nvidia
    local f = assert(io.popen('command -v nvidia-smi'))
    static_info.nvidia = f:read('*all') ~= ''
    f:close()

    if static_info.nvidia then
        add_query('nvidia gpuutil', 0)
        add_query('nvidia memutil', 0)
        add_query('nvidia gputemp', static_info.roomtemp)
    end

    for i = 0,static_info.ncpus do
        add_query('cpu cpu' .. i, 0)
        add_query('freq_g ' .. i, 0)
    end

    local temp_label_len = 0
    for i = 1,static_info.ntemps do
        local k = 'temp ' .. i
        add_query(table.concat({'platform', static_info.temppath, k}, ' '), static_info.roomtemp)
        local f = assert(io.open(concat(temp_prefix, static_info.temppath, '/temp', i, '_label')))
        local label = f:read('*all'):sub(1,-2)
        static_info[concat('temp', i, '_label')] = label
        f:close()
        temp_label_len = math.max(#label, temp_label_len)
    end
    for i = 1,static_info.ntemps do
        local x = string.format(
            concat('%-', temp_label_len, 's'),
            static_info['temp' .. i .. '_label']
        )
        static_info['temp' .. i .. '_label'] = string.rpad(static_info[concat('temp', i, '_label')], temp_label_len, ' ')
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
    add_query('fs_used_perc /', '')

    static_info.cquery = '${' .. table.concat(query_array, '}\n${') .. '}'

    static_info.memmax = conky_parse('${memmax}')
    static_info.swapmax = conky_parse('${swapmax}')
    static_info.rootsize = conky_parse('${fs_size /}')
    --static_info.homesize = conky_parse('${fs_size /home}'):gsub('%s', '')

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
    --if static_info.nvidia then
    --    dynamic_info['nvidia load'] = nvidia_load()
    --end
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

function conky_cpu (i)
    return concat(
        'CPU',
        i,
        '  ',
        string.format('%4s', dynamic_info['freq_g ' .. i]),
        ' GHz ',
        string.format('%3i', dynamic_info['cpu cpu' .. i]),
        '%'
    )
end

function conky_tempval (i)
    local x = dynamic_info[table.concat({'platform', static_info.temppath, 'temp', i}, ' ')]
    return (x  - static_info.roomtemp)*100/static_info.rantemp
end

function conky_temp_nolabel (i)
    return string.format('%3i', dynamic_info[table.concat({'platform', static_info.temppath, 'temp', i}, ' ')]) .. '°C'
end

function conky_temp (i)
    return concat(
        static_info[concat('temp', i, '_label')],
        ' ',
        string.format('%3i', dynamic_info[table.concat({'platform', static_info.temppath, 'temp', i}, ' ')]),
        '°C'
    )
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
        'GPU @ ${nvidia gpufreqcur} MHz ',
        dynamic_info['nvidia gpuutil'],
        '%'
    )
end

function conky_nvidia_mem ()
    return concat(
        'MEM @ ${nvidia memfreqcur} MHz ',
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
    -- %8.8s sets width to 8 and left pads with spaces
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
