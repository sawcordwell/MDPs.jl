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

       # transition probability types
       AbstractTransitionProbability,
       AbstractTransitionProbabilityArray,
       SparseTransitionProbabilityArray,
       TransitionProbabilityArray,
       TransitionProbabilityFunction,

       # reward types
       AbstractReward,
       AbstractRewardArray,
       Reward,  # constructor helper
       RewardArray,
       RewardVector,

       # functions
       bellman,
       bellman!,
       getvalue,
       is_square_stochastic,
       ismdp,
       num_actions,
       num_states,
       policy,
       probability,
       reset!,
       reward,
       setvalue!,
       value,
       value_iteration!


include("abstract.jl")
include("transition.jl")
include("reward.jl")
include("qfunction.jl")
include("bellman.jl")
include("dense.jl")
include("examples.jl")
include("utils.jl")

end # module
