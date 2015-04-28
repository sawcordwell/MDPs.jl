@doc """
Bellman operator.

# Arguments

* `Q::Array{V,2}`: The q-function array. Will be modified in-place.
* `value::Array{V,1}`: The previous value function.
* `transition::Array{P,3}`: Transition probability matrices.
* `reward::Array{R,2}`: The state-based rewards.
* `δ::Float64`: Discount fatcor.

# Returns

* `Q::Array{V,2}`: The modified q-function. Use it to calculate the new
  value-function and current policy.

# WARNING

Will not check that transition and reward specify a valid MDP. This method is
meant to be called by other methods that check the validity of the transition
and reward arrays. Consider using one of the MDP types instead.

""" ->
function bellman!(
    Q::AbstractQFunction,
    value_prev::Vector,
    P::AbstractTransitionProbability,
    R::AbstractReward,
    δ,
)
    0 < δ <= 1 || error("δ musy be in the interval (0, 1].")
    S = num_states(P)
    A = num_actions(P)
    S == num_states(R) == num_states(Q) == length(value_prev) || throw(DimensionMismatch())
    V = valuetype(Q)
    @inbounds for a = 1:A
        for s1 = 1:S
            Σ = zero(V)
            @simd for s0 = 1:S
                Σ += convert(V, probability(P, s0, s1, a)*value_prev[s0])
            end
            setvalue!(Q, convert(V, reward(R, s1, a) + δ*Σ), s1, a)
        end
    end
    return Q
end

function bellman!(Q, value_prev, P, R, δ)
    qfunction = bellman!(QFunction(Q), value_prev, TransitionProbability(P), Reward(R), δ)
    return qfunction.array
end

bellman(Q, value_prev, P, R, δ) =
    bellman!(copy(Q), value_prev, P, R, δ)

function bellman!(value, policy, value_prev, P, R, δ)
    qfunction = bellman!(QFunction(value, policy), value_prev, TransitionProbability(P), Reward(R), δ)
    return qfunction.value, qfunction.policy
end

bellman(value, policy, value_prev, P, R, δ) =
    bellman!(copy(value), copy(policy), value_prev, P, R, δ)
