import Base: convert, ndims, size



# --------------
# Abstract types
# --------------

@doc """
# Interface

* probability(P, s, t, a) -> the probability of transitioning from state s to state t given action a

""" ->
abstract AbstractTransitionProbability


@doc """
# Interface

* probability(P, a) -> probability transition matrix for action a

## Optional

* getindex(P, s, t, a) -> the probability of transitioning from state s to state t given action a

""" ->
abstract AbstractTransitionProbabilityArray <: AbstractTransitionProbability



# --------------
# Base functions
# --------------

ndims(P::AbstractTransitionProbabilityArray) = ndims(P.array)
size(P::AbstractTransitionProbabilityArray) = size(P.array)
size(P::AbstractTransitionProbabilityArray, dims...) = size(P.array, dims...)



# ----------
# Array type
# ----------

immutable TransitionProbabilityArray{T<:Real} <: AbstractTransitionProbabilityArray
    array::Array{T,3}

    function TransitionProbabilityArray(array::Array{T,3})
        is_square_stochastic(array) || error("Not valid transition probability.")
        new(array)
    end
end

TransitionProbabilityArray{T}(array::Array{T,3}) = TransitionProbabilityArray{T}(array)


num_actions(P::TransitionProbabilityArray) = size(P, 3)

num_states(P::TransitionProbabilityArray) = size(P, 1)


getindex(P::TransitionProbabilityArray, dims...) = getindex(P.array, dims...)


@doc """
# Transition probability

The probability of transitioning from state `s` to
state `t` given that action `a` is taken.

""" ->
probability(P::TransitionProbabilityArray, s, t, a) = getindex(P, s, t, a)

probability(P::TransitionProbabilityArray, a) = P[:, :, a]



# -----------------
# Sparse array type
# -----------------

immutable SparseTransitionProbabilityArray{Tv<:Real,Ti} <: AbstractTransitionProbabilityArray
    array::Vector{SparseMatrixCSC{Tv,Ti}}
end


num_actions(P::SparseTransitionProbabilityArray) = length(P.array)

num_states(P::SparseTransitionProbabilityArray) = size(getindex(P.array, 1), 1)


probability(P::SparseTransitionProbabilityArray, s, t, a) =
    getindex(getindex(P.array, a), s, t)

probability(P::SparseTransitionProbabilityArray, a) = getindex(P.array, a)



# -------------
# Function type
# -------------

immutable TransitionProbabilityFunction <: AbstractTransitionProbability
    func::Function
end


probability(P::TransitionProbabilityFunction, s, t, a) = P.func(s, t, a)
