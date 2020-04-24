atreplinit() do repl
    try
        sleep(0.1)
        @eval using Revise
        @async Revise.wait_steal_repl_backend()
    catch e
        @warn(e.msg)
    end
end
