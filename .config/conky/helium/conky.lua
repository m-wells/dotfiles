do
    ------------------------------------------------------------------------------------------------
    --Configuration Variables
    --number of cpus
    local config = {}
    config.ncpus = 8
    --number of temperature sensors
    config.ntemps = 5
    --patern for termperature label (%d will be replaced by a number)
    config.temp_label = "/sys/bus/platform/devices/coretemp.0/hwmon/hwmon5/temp%d_label"
    config.temp_pattern = "platform coretemp.0/hwmon/hwmon5 temp "
    --number of conky "${top ...}" values to show
    config. ntopcpu = 10
    --number of conky "${top_mem ...}" values to show
    config.ntopmem = 10

    config.roomtemp = 20   --ambient (room) temperature in degrees C
    config.hightemp = 100  --maximum temperature for temp graph

    loadfile(debug.getinfo(1).source:match("@(.*/conky/)").."conky.lua")(config)
end
