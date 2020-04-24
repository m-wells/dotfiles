isinteractive() && display(Base.banner())

try
    @eval using Revise
catch e
    @warn(e.msg)
end
