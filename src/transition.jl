import Base: convert, ndims, size

# Base array functions

ndims(P::AbstractTransitionProbabilityArray) = ndims(P.array)
size(P::AbstractTransitionProbabilityArray) = size(P.array)
size(P::AbstractTransitionProbabilityArray, dims...) = size(P.array, dims...)


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


immutable SparseTransitionProbabilityArray{Tv<:Real,Ti} <: AbstractTransitionProbabilityArray
    array::Vector{SparseMatrixCSC{Tv,Ti}}
end


num_actions(P::SparseTransitionProbabilityArray) = length(P.array)

num_states(P::SparseTransitionProbabilityArray) = size(getindex(P.array, 1), 1)

# getindex(P::SparseTransitionProbabilityArray, a, b, c) =
#     getindex(getindex(P.array, c), a, b)

probability(P::SparseTransitionProbabilityArray, s, t, a) =
    getindex(getindex(P.array, a), s, t)

probability(P::SparseTransitionProbabilityArray, a) = getindex(P.array, a)



immutable TransitionProbabilityFunction <: AbstractTransitionProbability
    func::Function
end


probability(P::TransitionProbabilityFunction, s, t, a) = P.func(s, t, a)
