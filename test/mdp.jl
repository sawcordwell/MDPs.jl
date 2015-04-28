# ---------------
# Value Iteration
# ---------------

facts("discounted dense value iteration") do
    P, R = MDPs.Examples.small()
    mdp = MDP(P, R)
    qfunc = value_iteration(mdp, 0.9)
    @fact policy(qfunc) == [2, 1] => true
    @fact value(qfunc) => roughly([40.048625392716815, 33.65371175967546])
end

facts("undiscounted dense value iteration") do
    P, R = MDPs.Examples.small()
    mdp = MDP(P, R)
    qfunc = value_iteration(mdp, 1)
    @fact policy(qfunc) == [2, 1] => true
    @fact value(qfunc) => roughly([117.84153597421569, 111.72677122062753])
end

facts("discounted sparse value iteration") do
    P, R = MDPs.Examples.sprandom(10, 3)
    mdp = MDP(P, R)
    qfunc = value_iteration(mdp, 0.9)
    @fact typeof(qfunc) => VectorQFunction{Float64,Int}
    @fact typeof(policy(qfunc)) => Vector{Int}
    @fact typeof(value(qfunc)) => Vector{Float64}
end

facts("MDP methods") do
    P = cat(3, eye(5), eye(5))
    R = [1 2 3 4 5; 5 4 3 2 1]'
    mdp = MDP(P, R)
    @fact reward(mdp, 2, 1) => 2
    @fact probability(mdp, 1, 1, 1) => 1
    @fact probability(mdp, 1, 2, 2) => 0
    @fact num_states(mdp) => 5
    @fact num_actions(mdp) => 2
end

facts("max iter too small") do
    warn(x) = "WARNING"
    P, R = MDPs.Examples.small()
    Q = value_iteration(MDP(P, R), 0.9, max_iter=5)
    @pending "test that there is a warning" => true
end
