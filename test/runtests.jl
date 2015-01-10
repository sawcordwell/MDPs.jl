module MDPsTests

using MDPs
using Base.Test

include("bellman.jl")
include("pomdp.jl")
include("random.jl")
include("sparse_random.jl")
include("value_iteration.jl")

end # module
