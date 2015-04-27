import Base: copy

# -------------
# Abstract type
# -------------

@doc """
# Interface

where Q is a subtype of AbstractQFunction

* policy(Q) -> a vector of the (currently) optimal policy for all states
* policy(Q, s) -> the (currently) optimal action to take at state s
* value(Q) -> a vector of the currently optimal values for all states
* value(Q, s) -> the value expected from state s given (currently) optimal actions are taken
* setvalue!(Q, v, s, a) -> set the value for state action
* num_states(Q) -> the number of states

## Optional

* getvalue(Q, s, a) -> the value expected from state s given action a is taken
* num_actions(Q) -> the number of actions

""" ->
abstract AbstractQFunction



# ----------
# Array type
# ----------

type ArrayQFunction{T<:Real} <: AbstractQFunction
    array::Array{T,2}
end

ArrayQFunction{T}(::Type{T}, states, actions) =
    ArrayQFunction(zeros(T, states, actions))

ArrayQFunction(states, actions) = ArrayQFunction(Float64, states, actions)


QFunction(A::Matrix) = ArrayQFunction(A)


# Base methods
# ------------

==(a::ArrayQFunction, b::ArrayQFunction) = a.array == b.array

isequal(a::ArrayQFunction, b::ArrayQFunction) = isequal(a.array, b.array)

copy(Q::ArrayQFunction) = ArrayQFunction(copy(Q.array))


# Size methods
# ------------

num_actions(Q::ArrayQFunction) = size(Q.array, 2)

num_states(Q::ArrayQFunction) = size(Q.array, 1)


# Value methods
# -------------

value(Q::ArrayQFunction, state) = maximum(Q.array[state, :])

function value!(A::Vector, Q::ArrayQFunction)
    for s = 1:num_states(Q)
        A[s] = value(Q, s)
    end
    return A
end

value{T}(Q::ArrayQFunction{T}) = value!(Array(T, num_states(Q)), Q)

getvalue(Q::ArrayQFunction, state, action) = getindex(Q.array, state, action)

setvalue!(Q::ArrayQFunction, v, state, action) =
    (setindex!(Q.array, v, state, action); Q)

valuetype{T}(Q::ArrayQFunction{T}) = T


# Policy methods
# --------------

policy(Q::ArrayQFunction, state) = indmax(Q.array[state, :])

function policy!(A::Vector, Q::ArrayQFunction)
    for s = 1:num_states(Q)
        A[s] = policy(Q, s)
    end
    return A
end

policy{T}(::Type{T}, Q::ArrayQFunction) = policy!(Array(T, num_states(Q)), Q)

policy(Q::ArrayQFunction) = policy(Int, Q)



# -----------
# Vector type
# -----------

type VectorQFunction{V<:Real,A<:Integer} <: AbstractQFunction
    value::Vector{V}
    policy::Vector{A}

    function VectorQFunction(value::Vector{V}, policy::Vector{A})
        length(value) == length(policy) || throw(
            DimensionMismatch("The lengths of value and policy must match.")
        )
        new(value, policy)
    end
end

VectorQFunction{V,A}(value::Vector{V}, policy::Vector{A}) =
    VectorQFunction{V,A}(value, policy)

VectorQFunction{V,A}(::Type{V}, ::Type{A}, states) =
    VectorQFunction(zeros(V, states), zeros(A, states))

VectorQFunction(states) = VectorQFunction(Float64, Int, states)


QFunction(A::Vector, B::Vector) = VectorQFunction(A, B)


# Base methods
# ------------

==(a::VectorQFunction, b::VectorQFunction) =
    (a.value == b.value) & (a.policy == b.policy)

isequal(a::ArrayQFunction, b::ArrayQFunction) =
    isequal(a.value, b.value) & isequal(a.policy, b.policy)

copy(Q::VectorQFunction) = VectorQFunction(copy(Q.value), copy(Q.policy))


# Size methods
# ------------

# VectorQFunction can not calculate the number of actions so cannot define
# num_actions(Q::VectorQFunction)

num_states(Q::VectorQFunction) = length(Q.value)


# Value methods
# -------------

value!(A::Vector, Q::VectorQFunction) = copy!(A, Q.value)

value(Q::VectorQFunction) = Q.value

value(Q::VectorQFunction, state) = getindex(Q.value, state)

@doc """
Returns negative infinity if `a` is not the optimal action.
""" ->
getvalue{V,A}(Q::VectorQFunction{V,A}, s, a) = Q.policy[s] == a ? Q.value[s] : convert(V, -Inf)

function setvalue!(Q::VectorQFunction, v, state, action)
    if v > value(Q, state)
        setindex!(Q.value, v, state)
        setindex!(Q.policy, action, state)
    end
    return Q
end

valuetype{V,A}(Q::VectorQFunction{V,A}) = V


# Policy methods
# --------------

policy!(A::Vector, Q::VectorQFunction) = copy!(A, Q.policy)

policy(Q::VectorQFunction) = Q.policy

policy(Q::VectorQFunction, state) = getindex(Q.policy, state)
