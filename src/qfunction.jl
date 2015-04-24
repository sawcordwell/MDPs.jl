
# ----------
# Array type
# ----------

type ArrayQFunction{T<:Real} <: AbstractQFunction
    array::Array{T,2}
end

ArrayQFunction{T}(::Type{T}, states, actions) =
    ArrayQFunction(zeros(T, states, actions))

ArrayQFunction(states, actions) = ArrayQFunction(Float64, states, actions)


==(a::ArrayQFunction, b::ArrayQFunction) = a.array == b.array

isequal(a::ArrayQFunction, b::ArrayQFunction) = isequal(a.array, b.array)


num_actions(Q::ArrayQFunction) = size(Q.array, 2)

num_states(Q::ArrayQFunction) = size(Q.array, 1)


value(Q::ArrayQFunction, state) = maximum(Q.array[state, :])

value{T}(Q::ArrayQFunction{T}) = T[ value(Q, s) for s = 1:num_states(Q) ]


policy(Q::ArrayQFunction, state) = indmax(Q.array[state, :])

policy{T}(::Type{T}, Q::ArrayQFunction) =
    T[ policy(Q, s) for s = 1:num_states(Q) ]

policy(Q::ArrayQFunction) = policy(Int, Q)


getvalue(Q::ArrayQFunction, state, action) = getindex(Q.array, state, action)

setvalue!(Q::ArrayQFunction, v, state, action) =
    (setindex!(Q.array, v, state, action); Q)


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


==(a::VectorQFunction, b::VectorQFunction) =
    (a.value == b.value) & (a.policy == b.policy)

isequal(a::ArrayQFunction, b::ArrayQFunction) =
    isequal(a.value, b.value) & isequal(a.policy, b.policy)


# VectorQFunction can not calculate the number of actions so cannot define
# num_actions(Q::VectorQFunction)

num_states(Q::VectorQFunction) = length(Q.value)


value(Q::VectorQFunction) = Q.value

value(Q::VectorQFunction, state) = getindex(Q.value, state)


policy(Q::VectorQFunction) = Q.policy

policy(Q::VectorQFunction, state) = getindex(Q.policy, state)


# VectorQFunction does not store state-action pairs so cannot define
# getvalue(Q::VectorQFunction, s, a)

function setvalue!(Q::VectorQFunction, v, state, action)
    if v > value(Q, state)
        setindex!(Q.value, v, state)
        setindex!(Q.policy, action, state)
    end
    return Q
end
