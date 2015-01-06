
function update_value{P,R,V}(s, j, k, transition::Array{P,3}, value::Vector{V},
                             reward::R, δ)
  Σ = zero(V)
  @simd for i = 1:s
    @inbounds Σ += convert(V, transition[i, j, k] * value[i])
  end
  return convert(V, reward + δ*Σ)
end

@doc """
Bellman operator for when rewards are based on state-action pairs.

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
function bellman!{P,R,V}(Q::Array{V,2}, value::Vector{V},
                         transition::Array{P,3}, reward::Array{R,2}, δ)
  s1, s2, a = size(transition)
  @assert length(value) == s1
  @assert size(reward) == (s2, a)
  @assert size(Q) == (s2, a)
  @inbounds for k = 1:a
    for j = 1:s2
      Q[j, k] = update_value(s1, j, k, transition, value, reward[j, k], δ)
    end
  end
  return Q
end

@doc """
Bellman operator for when rewards are based on state alone.

# Arguments

* `Q::Array{V,2}`: The q-function array. Will be modified in-place.
* `value::Array{V,1}`: The previous value function.
* `transition::Array{P,3}`: Transition probability matrices.
* `reward::Vector{R}`: The state-based rewards.
* `δ::Float64`: Discount fatcor.

# Returns

* `Q::Array{V,2}`: The modified q-function. Use it to calculate the new
  value-function and current policy.

# WARNING

Will not check that transition and reward specify a valid MDP. This method is
meant to be called by other methods that check the validity of the transition
and reward arrays. Consider using one of the MDP types instead.

""" ->
function bellman!{P,R,V}(Q::Array{V,2}, value::Vector{V},
                         transition::Array{P,3}, reward::Vector{R}, δ)
  s1, s2, a = size(transition)
  @assert length(value) == s1
  @assert length(reward) == s2
  @assert size(Q) == (s2, a)
  @inbounds for k = 1:a
    for j = 1:s2
      Q[j, k] = update_value(s1, j, k, transition, value, reward[j], δ)
    end
  end
  return Q
end

@doc """
Updates value and policy inline
""" ->
function bellman!{P,R,V,A}(value::Vector{V}, policy::Vector{A},
                           value_prev::Vector{V}, transition::Array{P,3},
                           reward::Array{R,2}, δ)
  s1, s2, a = size(transition)
  @assert s1 == length(value) == length(value_prev)
  @assert size(reward) == (s2, a)
  @inbounds for k = 1:a
    for j = 1:s2
      q = update_value(s1, j, k, transition, value_prev, reward[j, k], δ)
      if value[j] < q
        value[j] = convert(V, q)
        policy[j] = convert(A, k)
      end
    end
  end
  return value
end

@doc """
Updates value and policy inline: vector reward
""" ->
function bellman!{P,R,V,A}(value::Vector{V}, policy::Vector{A},
                           value_prev::Vector{V}, transition::Array{P,3},
                           reward::Vector{R}, δ)
  s1, s2, a = size(transition)
  @assert s1 == length(value) == length(value_prev)
  @assert length(reward) == s2
  @inbounds for k = 1:a
    for j = 1:s2
      q = update_value(s1, j, k, transition, value_prev, reward[j], δ)
      if value[j] < q
        value[j] = convert(V, q)
        policy[j] = convert(A, k)
      end
    end
  end
  return value
end

@doc """
# The Bellman operator from Bellman R (1957) "A Markovian decision process"

# Arguments

Let S be the number of states and A be the nnumber of actions, then

* `value::Vector{V}`: The previous value vector. S × 1
* `transition::Array{P,3}`: The transition probability matrices. The columns
  must sum to one. S × S × A
* `reward::Array{R,2}`: The state-action reward vectors. S × A
* `δ::Float64`: The discount factor, 0 < discount ≤ 1
* `policy::Bool`: Whether the policy should also be returned.
  Optional (default: false).

# Returns

A tuple of the new value vector and, optionaly, the policy.

""" ->
function bellman{P,R,V}(value::Array{V,1}, transition::Array{P,3},
                        reward::Union(Vector{R},Array{R,2}), δ;
                        policy=false)
  @assert 0 < δ <= 1 "ERROR: δ not in interval (0, 1]"
  ismdp(transition, reward) || error("Not a valid MDP.")
  s1, s2, a = size(transition)
  Q = bellman!(Array(V, s2, a), value, transition, reward, δ)
  new_value = V[ maximum(Q[i, :]) for i = 1:s1 ]
  if policy
    return (new_value, [ indmax(Q[i, :]) for i = 1:s1 ])
  end
  return new_value
end

@doc """
Modfies value in-place.
""" ->
function bellman!{P,R,V}(value::Array{V,1}, transition::Array{P,3},
                         reward::Union(Vector{R},Array{R,2}), δ;
                         policy=false)
  @assert 0 < δ <= 1 "ERROR: δ not in interval (0, 1]"
  ismdp(transition, reward) || error("Not a valid MDP.")
  s1, s2, a = size(transition)
  Q = bellman!(Array(V, s2, a), value, transition, reward, δ)
  @inbounds if policy
    p = Array(Int, s1)
    for i = 1:s1
      value[i] = maximum(Q[i, :])
      p[i] = indmax(Q[i, :])
    end
    return p
  else
    for i = 1:s1
      value[i] = maximum(Q[i, :])
    end
  end
end
