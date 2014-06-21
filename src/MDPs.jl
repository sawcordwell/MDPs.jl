module MDPs
    export AbstractMDP,
           MDP,
           SparseMDP,
           bellman!,
           is_square_stochastic,
           ismdp,
           policy,
           randmdp,
           value,
           value_iteration!

    include("abstractmdp.jl")
    include("examples.jl")
    include("mdp.jl")
    include("sparsemdp.jl")
    include("utils.jl")
end
