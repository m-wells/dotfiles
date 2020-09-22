if Base.VERSION < v"1.5"
    atreplinit() do repl
        try
            sleep(0.1)
            @eval using Revise
            @async Revise.wait_steal_repl_backend()
        catch e
            @warn(e.msg)
        end
    end
else
    try
        using Revise
    catch e
        @warn(e)
    end
end
