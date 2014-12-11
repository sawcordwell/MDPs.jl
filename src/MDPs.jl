module MDPs

if VERSION < v"0.4-dev"
  using Docile
end

export AbstractMDP,
       DenseMDP,
       QMDP,
       MDP,
       bellman,
       bellman!,
       is_square_stochastic,
       ismdp,
       policy,
       randmdp,
       reset!,
       smallmdp,
       value,
       value_iteration!


include("abstract.jl")
include("bellman.jl")
include("dense.jl")
include("examples.jl")
include("rand.jl")
include("utils.jl")

end # module
