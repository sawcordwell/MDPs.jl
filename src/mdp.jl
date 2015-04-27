abstract AbstractMDP


# -----------------------------------------------------
# Methods that should work for all types of AbstractMDP
# -----------------------------------------------------

reward(mdp::AbstractMDP, s, t, a) = reward(mdp.reward, s, t, a)
probability(mdp::AbstractMDP, s, t, a) = probability(mdp.transition, s, t, a)
num_states(mdp::AbstractMDP) = mdp.n_states
num_actions(mdp::AbstractMDP) = mdp.n_actions


# ------------
# The MDP type
# ------------

immutable MDP <: AbstractMDP
    transition::AbstractTransitionProbability
    reward::AbstractReward
    n_states::Int
    n_actions::Int

    function MDP(transition::AbstractTransitionProbability, reward::AbstractReward)
        ismdp(transition, reward) || error("Not a valid MDP.")
        n_states, n_actions = size(transition)[[1,3]]
        new(transition, reward, n_states, n_actions)
    end
end

MDP(transition, reward) = MDP(TransitionProbability(transition), Reward(reward))


# Methods
# -------

@doc """
# Value iteration algorithm from Bellman 1957 "A Markovian decision process."

## Arguments

* `Q::AbstractQFunction`: The Q-function
* `mdp::MDP`: The Markov decision process of type MDP.
* `δ`: The discount factor, 0 < discount ≤ 1.
* `ϵ`: The epsilon-optimal stopping value. Default: 0.01
* `max_iter`: The maximum number of iterations. Default: 1000.

## Returns

* `Q::AbstractQFunction`: The Q-function (modified in-place).

""" ->
function value_iteration!(Q::AbstractQFunction, mdp::MDP, δ; ϵ=0.01, max_iter=1000)
    @assert 0 < δ <= 1 "ERROR: δ not in interval (0, 1]"
    @assert ϵ > 0 "ERROR: ϵ not greater than 0"
    @assert max_iter > 0 "ERROR: max_iter not greater than 0"
    # Calculate the stopping threshold
    if δ < 1.0
        threshold = ϵ*(1.0 - δ)/δ
    else
        threshold = ϵ
    end
    val = Array(valuetype(Q), num_states(mdp))
    value!(val, Q)  # initial value
    # Find the ϵ-optimal value function
    itr = 0
    while true
        itr += 1
        bellman!(Q, val, mdp.transition, mdp.reward, δ)
        val_new = value(Q)
        if span(val_new - val) < threshold
            break
        elseif itr == max_iter
            warn("Reached maximum number of iterations, ϵ-optimal policy not found.")
            break
        end
        copy!(val, val_new)
    end
    return Q
end

function value_iteration(
    mdp::MDP,
    δ;
    ϵ=0.01,
    max_iter=1000,
    initial_value::Nullable{Vector}=Nullable{Vector}(),
)
    S = num_states(mdp)
    val = isnull(initial_value) ? zeros(S) : get(initial_value)
    return value_iteration!(QFunction(val, zeros(Int, S)), mdp, δ, ϵ=ϵ, max_iter=max_iter)
end
