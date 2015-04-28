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
abstract AbstractArrayTransitionProbability <: AbstractTransitionProbability



# --------------
# Base functions
# --------------

ndims(P::AbstractArrayTransitionProbability) = ndims(P.array)
size(P::AbstractArrayTransitionProbability) = size(P.array)
size(P::AbstractArrayTransitionProbability, dims...) = size(P.array, dims...)



# ----------
# Array type
# ----------

immutable ArrayTransitionProbability{T<:Real} <: AbstractArrayTransitionProbability
    array::Array{T,3}

    function ArrayTransitionProbability(array::Array{T,3})
        is_square_stochastic(array) || error("Not valid transition probability.")
        new(array)
    end
end

ArrayTransitionProbability{T}(array::Array{T,3}) = ArrayTransitionProbability{T}(array)


TransitionProbability{T}(A::Array{T,3}) = ArrayTransitionProbability(A)


num_actions(P::ArrayTransitionProbability) = size(P, 3)

num_states(P::ArrayTransitionProbability) = size(P, 1)


getindex(P::ArrayTransitionProbability, dims...) = getindex(P.array, dims...)


@doc """
# Transition probability

The probability of transitioning from state `s` to
state `t` given that action `a` is taken.

""" ->
probability(P::ArrayTransitionProbability, s, t, a) = getindex(P, s, t, a)

probability(P::ArrayTransitionProbability, a) = P[:, :, a]



# -----------------
# Sparse array type
# -----------------

immutable SparseArrayTransitionProbability{Tv<:Real,Ti} <: AbstractArrayTransitionProbability
    array::Vector{SparseMatrixCSC{Tv,Ti}}
end


TransitionProbability{T<:SparseMatrixCSC}(A::Vector{T}) =
    SparseArrayTransitionProbability(A)


num_actions(P::SparseArrayTransitionProbability) = length(P.array)

num_states(P::SparseArrayTransitionProbability) = size(getindex(P.array, 1), 1)


probability(P::SparseArrayTransitionProbability, s, t, a) =
    getindex(getindex(P.array, a), s, t)

probability(P::SparseArrayTransitionProbability, a) = getindex(P.array, a)



# -------------
# Function type
# -------------

immutable TransitionProbabilityFunction <: AbstractTransitionProbability
    func::Function
end


TransitionProbability(F::Function) = TransitionProbabilityFunction(F)


probability(P::TransitionProbabilityFunction, s, t, a) = P.func(s, t, a)
