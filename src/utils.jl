@doc """
Check that a matrix is square and column-stochastic.

# Arguments

* `M::AbstractMatrix`: Column-stochastic square matrix.

# Returns

`true` if M is square and column-stochastic, `false` otherwise.

""" ->
function is_square_stochastic{T}(M::AbstractMatrix{T})
    r, c = size(M)
    r == c || return false
    for j = 1:c
        S = zero(T)
        @simd for i = 1:r
            @inbounds S += M[i, j]
        end
        isapprox(S, one(T)) || return false
    end
    return true
end

@doc """
Check that the matrices along the third axis are square and column-stochastic.

# Arguments

* `A::AbstractMatrix`: Column-stochastic square matrices.

# Returns

`true` if A is square and column-stochastic, `false` otherwise.

""" ->
function is_square_stochastic{_}(A::AbstractArray{_,3})
    for k = 1:size(A, 3)
        is_square_stochastic(A[:, :, k]) || return false
    end
    return true
end

function is_square_stochastic(A::Vector)
    for k = 1:length(A)
        is_square_stochastic(A[k]) || return false
    end
    return true
end



function ismdp{_}(transition::AbstractArray{_,3}, reward::AbstractVector)
    # number of rows, columns and actions according to the transition
    # probability matrix
    ST = size(transition, 1)
    # number of states according to reward vector
    SR = length(reward)
    # number of transition states must equal number of reward states
    return (ST == SR) && is_square_stochastic(transition)
end

function ismdp{_}(transition::AbstractArray{_,3}, reward::AbstractMatrix)
    ST, AT = size(transition)[[1, 3]]
    SR, AR = size(reward)
    return (ST == SR) && (AT == AR) && is_square_stochastic(transition)
end

function ismdp{P,R}(transition::AbstractArray{P,3}, reward::AbstractArray{R,3})
    S1T, S2T, AT = size(transition)
    S1R, S2R, AR = size(reward)
    return (S1T == S1R) && (S2T == S2R) && (AT == AR) && is_square_stochastic(transition)
end

_all_row_lengths_equal(len, vec::AbstractVector) = all([len == size(vec[k], 1) for k = 1:length(vec)])

function ismdp(transition::Vector, reward::AbstractVector)
    AT = length(transition)
    SR = length(reward)
    return _all_row_lengths_equal(SR, transition) && is_square_stochastic(transition)
end

function ismdp(transition::Vector, reward::AbstractMatrix)
    AT = length(transition)
    SR, AR = size(reward)
    return (AT == AR) && _all_row_lengths_equal(SR, transition) && is_square_stochastic(transition)
end

function ismdp{_}(transition::Vector, reward::AbstractArray{_,3})
    AT = length(transition)
    S1R, S2R, AR = size(reward)
    return (AT == AR) && (S1R == S2R) && _all_row_lengths_equal(S1R, transition) && is_square_stochastic(transition)
end

ismdp(transition::AbstractTransitionProbability, reward::AbstractReward) =
    ismdp(transition.array, reward.array)

ismdp(mdp::MDP) = ismdp(mdp.transition, mdp.reward)



span(a::AbstractArray) = maximum(a) - minimum(a)
