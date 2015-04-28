
facts("Transition probability types") do
    @fact AbstractArrayTransitionProbability <: AbstractTransitionProbability => true
    @fact ArrayTransitionProbability <: AbstractArrayTransitionProbability => true
    @fact SparseArrayTransitionProbability <: AbstractArrayTransitionProbability => true
    @fact MDPs.TransitionProbabilityFunction <: AbstractTransitionProbability => true
end

facts("ArrayTransitionProbability methods") do
    P = ArrayTransitionProbability(cat(3, eye(5), eye(5)))
    @fact probability(P, 1, 1, 1) => 1.0
    @fact probability(P, 1, 2, 1) => 0.0
    @fact P[1, :, 1] => [1.0 0.0 0.0 0.0 0.0]
    @fact probability(P, 1) => eye(5)
    @fact num_states(P) => 5
    @fact num_actions(P) => 2
end

facts("SparseArrayTransitionProbability methods") do
    P = SparseArrayTransitionProbability([ speye(5) for x=1:2 ])
    @fact probability(P, 1, 1, 1) => 1.0
    @fact probability(P, 1, 2, 1) => 0.0
    @fact probability(P, 1) => speye(5)
    @fact num_states(P) => 5
    @fact num_actions(P) => 2
end

facts("TransitionProbabilityFunction methods") do
    P = MDPs.TransitionProbabilityFunction((s, t, a) -> s == t ? 1 : 0)
    @fact probability(P, 1, 1, 1) => 1
    @fact probability(P, 1, 2, 1) => 0
end

facts("helper constructor") do
    @fact typeof(TransitionProbability(cat(3, eye(5), eye(5)))) =>
        ArrayTransitionProbability{Float64}
    @fact typeof(TransitionProbability([ speye(5) for x=1:2 ])) =>
        SparseArrayTransitionProbability{Float64,Int}
    @fact typeof(TransitionProbability((s, t, a) -> s == t ? 1 : 0)) =>
        MDPs.TransitionProbabilityFunction
end
