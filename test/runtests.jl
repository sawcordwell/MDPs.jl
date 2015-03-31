module MDPsTests

using MDPs
using Base.Test

if VERSION < v"0.4-"
    using Compat
end

include("fixtures.jl")
include("bellman.jl")
include("dense.jl")
include("random.jl")
include("sparse_random.jl")

end # module
