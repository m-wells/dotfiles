atreplinit() do repl
    try
        sleep(0.1)
        @eval using Revise
        @async Revise.wait_steal_repl_backend()
    catch e
        @warn(e.msg)
    end

    try
        @eval using REPL
        @eval using REPL: LineEdit

        repl.interface = REPL.setup_interface(repl)
        repl.interface.modes[1].on_enter = function (s)
            mktemp() do path, io
                input = chomp(String(take!(copy(LineEdit.buffer(s)))))
                if isempty(input)
                    run(`vim -c "set filetype=julia" $(path)`)
                    sleep(0.1)
                    input = read(io, String)
                    write(LineEdit.buffer(s), chomp(input))
                end
                ast = Base.parse_input_line(String(take!(copy(LineEdit.buffer(s)))), depwarn=false)
                return !(isa(ast, Expr) && ast.head === :incomplete)
            end
        end
    catch e
        @warn(e)
    end
end
