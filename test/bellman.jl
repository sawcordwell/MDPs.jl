
facts("VectorQFunction with in-place bellman!") do
    qfunc = VectorQFunction(fixture_num_states())
    trans = TransitionProbability(fixture_transition())
    reward = Reward(fixture_reward())
    bellman!(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
    @fact value(qfunc) => roughly(fixture_expected_value())
    @fact policy(qfunc) == fixture_expected_policy() => true
end

facts("VectorQFunction with bellman") do
    qfunc = VectorQFunction(fixture_num_states())
    trans = TransitionProbability(fixture_transition())
    reward = Reward(fixture_reward())
    newq = bellman(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
    @fact value(newq) => roughly(fixture_expected_value())
    @fact policy(newq) == fixture_expected_policy() => true
    @fact all(map((x, y) -> isapprox(x, y), value(qfunc), fixture_expected_value())) => false
    @fact policy(qfunc) == fixture_expected_policy() => false
end

facts("ArrayQFunction with bellman!") do
    qfunc = ArrayQFunction(fixture_num_states(), fixture_num_actions())
    trans = TransitionProbability(fixture_transition())
    reward = Reward(fixture_reward())
    bellman!(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
    @fact value(qfunc) => roughly(fixture_expected_value())
    @fact policy(qfunc) == fixture_expected_policy() => true
end

facts("SparseTransitionProbabilityArray with bellman!") do
    qfunc = ArrayQFunction(fixture_num_states(), fixture_num_actions())
    T = SparseMatrixCSC{Float64,Int}
    array = fixture_transition()
    array = T[ sparse(array[:, :, a]) for a=1:fixture_num_actions() ]
    trans = TransitionProbability(array)
    reward = Reward(fixture_reward())
    bellman!(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
    @fact value(qfunc) => roughly(fixture_expected_value())
    @fact policy(qfunc) == fixture_expected_policy() => true
end

# There is no yet a Bellman operator function that works with
# TransitionProbabilityFunction
# facts("TransitionProbabilityFunction with bellman!") do
#     qfunc = ArrayQFunction(fixture_num_states(), fixture_num_actions())
#     array = fixture_transition()
#     trans = TransitionProbability((s, t, a) -> array[s, t, a])
#     reward = Reward(fixture_reward())
#     bellman!(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
#     @fact value(qfunc) => roughly(fixture_expected_value())
#     @fact policy(qfunc) == fixture_expected_policy() => true
# end

facts("ArrayReward with bellman!") do
    qfunc = VectorQFunction(fixture_num_states())
    trans = TransitionProbability(fixture_transition())
    reward = Reward(fixture_reward(:array))
    bellman!(qfunc, fixture_initial_value(), trans, reward, fixture_discount())
    @fact value(qfunc) => roughly(fixture_expected_value(:array))
    @fact policy(qfunc) == fixture_expected_policy(:array) => true
end

facts("bellman can be called with arrays") do
    Q = zeros(5, 3)
    newQ = bellman(Q, fixture_initial_value(), fixture_transition(), fixture_reward(), fixture_discount())
    @fact typeof(newQ) => Array{Float64,2}
    @fact Q == newQ => false
    @fact Float64[ maximum(newQ[s, :]) for s=1:5 ] => roughly(fixture_expected_value())
    @fact Int[ indmax(newQ[s, :]) for s=1:5 ] == fixture_expected_policy() => true
end

facts("bellman can be called with vectors") do
    value = zeros(5)
    policy = zeros(Int, 5)
    newVal, newPol = bellman(value, policy, fixture_initial_value(), fixture_transition(), fixture_reward(), fixture_discount())
    @fact typeof(newVal) => Vector{Float64}
    @fact typeof(newPol) => Vector{Int}
    @fact value == newVal => false
    @fact policy == newPol => false
    @fact newVal => roughly(fixture_expected_value())
    @fact newPol == fixture_expected_policy() => true
end

facts("bellman! can be called with arrays") do
    Q = zeros(5, 3)
    newQ = bellman!(Q, fixture_initial_value(), fixture_transition(), fixture_reward(), fixture_discount())
    @fact Q === newQ => true
    @fact Float64[ maximum(newQ[s, :]) for s=1:5 ] => roughly(fixture_expected_value())
    @fact Int[ indmax(newQ[s, :]) for s=1:5 ] == fixture_expected_policy() => true
end

facts("bellman! can be called with vectors") do
    value = zeros(5)
    policy = zeros(Int, 5)
    newVal, newPol = bellman!(value, policy, fixture_initial_value(), fixture_transition(), fixture_reward(), fixture_discount())
    @fact value === newVal => true
    @fact policy === newPol => true
    @fact value => roughly(fixture_expected_value())
    @fact policy == fixture_expected_policy() => true
end
