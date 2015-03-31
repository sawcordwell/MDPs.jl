module MDPsTests

using MDPs
using Base.Test

if VERSION < v"0.4-"
    using Compat
end

include("bellman.jl")
include("random.jl")
include("sparse_random.jl")
include("value_iteration.jl")

end # module
