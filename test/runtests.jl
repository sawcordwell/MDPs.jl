module MDPsTests

using MDPs
using Base.Test

using Compat

include("fixtures.jl")
include("bellman.jl")
include("dense.jl")
include("random.jl")
include("sparse_random.jl")

end # module
