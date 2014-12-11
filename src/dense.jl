# --------------------------------------------------
# Methods that should work for all types of DenseMDP
# --------------------------------------------------

reward(mdp::DenseMDP) = mdp.reward
transition(mdp::DenseMDP) = mdp.transition
num_states(mdp::DenseMDP) = mdp.n_states
num_actions(mdp::DenseMDP) = mdp.n_actions

# -----------------------
# The standard dense type
# -----------------------

type MDP{P,R,V<:FloatingPoint,A<:Integer} <: DenseMDP{P,R}
  transition::Array{P,3}
  reward::Union(Vector{R},Array{R,2})
  value::Vector{V}
  value_prev::Vector{V}
  policy::Vector{A}
  n_states::Int
  n_actions::Int
end

function MDP{P,R,V,A}(transition::Array{P,3},
                      reward::Union(Vector{R},Array{R,2}),
                      value::Vector{V},
                      value_prev::Vector{V},
                      policy::Vector{A},
                      n_states::Int,
                      n_actions::Int)
  ismdp(transition, reward) || error("Not a valid MDP.")
  @assert n_states == length(value) == length(policy) == length(value_prev)
  new(transition, reward, value, value_prev, policy, n_states, n_actions)
end

function MDP{P,R,V,A}(transition::Array{P,3},
                      reward::Union(Vector{R},Array{R,2}),
                      initial_value::Vector{V},
                      ::Type{A})
  n_states, n_actions = size(transition)[[1,3]]
  MDP(transition, reward, fill(typemin(V), n_states), copy(initial_value),
      ones(A, n_states), n_states, n_actions)
end

MDP{P,R,V,A}(transition::Array{P,3}, reward::Union(Vector{R},Array{R,2}),
             ::Type{V}, ::Type{A}) =
  MDP(transition, reward, zeros(V, size(transition)[1]), A)

MDP{P,R,V}(transition::Array{P,3}, reward::Union(Vector{R},Array{R,2}),
           initial_value::Vector{V}) =
  MDP(transition, reward, initial_value, Int64)

MDP{P,R}(transition::Array{P,3}, reward::Union(Vector{R},Array{R,2})) =
  MDP(transition, reward, Float64, Int64)

value(mdp::MDP) = mdp.value
policy(mdp::MDP) = mdp.policy

initial_value!{P,R,V,A}(mdp::MDP{P,R,V,A}, value::Vector{V}) =
  copy!(mdp.value_prev, value)

function reset!{P,R,V,A}(mdp::MDP{P,R,V,A})
  for i = 1:mdp.n_states
    mdp.value[i] = zero(V)
    mdp.value_prev[i] = zero(V)
    mdp.policy[i] = one(A)
  end
  nothing
end

bellman!{P,R,V,A}(mdp::MDP{P,R,V,A}, δ::Float64) =
  bellman!(mdp.value, mdp.policy, mdp.value_prev, mdp.transition,
           mdp.reward, δ)

# ---------------------------------------
# A dense type that stores the q-function
# ---------------------------------------

type QMDP{P,R,V<:FloatingPoint} <: DenseMDP{P,R}
  transition::Array{P,3}
  reward::Union(Vector{R},Array{R,2})
  q::Array{V,2}
  n_states::Int
  n_actions::Int
end

# Constructors
# ------------

function QMDP{P,R,V}(transition::Array{P,3},
                     reward::Union(Vector{R},Array{R,2}),
                     qfunction::Array{V,2},
                     n_states::Int,
                     n_actions::Int)
  ismdp(transition, reward) || error("Not a valid MDP.")
  @assert size(qfunction) == (n_states, n_actions)
  new(transition, reward, qfunction, n_states, n_actions)
end

function QMDP{P,R,V}(transition::Array{P,3},
                     reward::Union(Vector{R},Array{R,2}),
                     ::Type{V})
  n_states, n_actions = size(transition)[[1,3]]
  QMDP(transition, reward, zeros(V, n_states, n_actions), n_states, n_actions)
end

QMDP{P,R}(transition::Array{P,3}, reward::Union(Vector{R},Array{R,2})) =
  QMDP(transition, reward, Float64)

# Accessors
# ---------

reset!{P,R,V}(mdp::QMDP{P,R,V}) = (fill!(mdp.q, zero(V)); nothing)

policy(mdp::QMDP) = [ indmax(mdp.q[s, :]) for s = 1:mdp.n_states ]
policy{A}(::Type{A}, mdp::QMDP) = A[ indmax(mdp.q[s, :]) for s = 1:mdp.n_states ]

value{P,R,V}(mdp::QMDP{P,R,V}) = V[ maximum(mdp.q[s, :]) for s = 1:mdp.n_states ]

# Methods
# -------

@doc """
# The Bellman operator from Bellman R (1957) "A Markovian decision process"

# Arguments

* `mdp::MDP{P,R,V}`: The Markov decision process of type MDP
* `value::Vector{V}`: The previous value function
* `δ::Float64`: The discount factor, 0 < discount ≤ 1

""" ->
bellman!{P,R,V}(mdp::QMDP{P,R,V}, value::Vector{V}, δ::Float64) =
  bellman!(mdp.q, value, mdp.transition, mdp.reward, δ)
