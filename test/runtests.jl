module MDPsTests

using MDPs

using Compat
using Base.Test
using FactCheck

include("fixtures.jl")

include("bellman.jl")
include("mdp.jl")
include("qfunction.jl")
include("random.jl")
include("reward.jl")
include("sparse_random.jl")
include("transition.jl")

FactCheck.exitstatus()

end # module
