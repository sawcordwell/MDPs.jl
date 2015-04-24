module MDPs

if VERSION < v"0.4-dev"
  using Docile
end

export # MDP types
       AbstractMDP,
       DenseMDP,
       QMDP,
       MDP,

       # Q function types
       AbstractQFunction,
       ArrayQFunction,
       VectorQFunction,

       # functions
       bellman,
       bellman!,
       getvalue,
       is_square_stochastic,
       ismdp,
       num_actions,
       num_states,
       policy,
       reset!,
       setvalue!,
       value,
       value_iteration!


include("abstract.jl")
include("qfunction.jl")
include("bellman.jl")
include("dense.jl")
include("examples.jl")
include("utils.jl")

end # module
