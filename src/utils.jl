@doc """
Check that a matrix is square and column-stochastic.

# Arguments

* `M::AbstractMatrix`: Column-stochastic square matrix.

# Returns

`true` if M is square and column-stochastic, `false` otherwise.

""" ->
function is_square_stochastic{T<:FloatingPoint}(M::AbstractMatrix{T})
  r, c = size(M)
  r == c || return false
  eps_multiplier = 10
  for j = 1:c
    S = zero(T)
    @simd for i = 1:r
      @inbounds S += M[i, j]
    end
    x = S < one(T) ? one(T) : S
    abs(S - one(T)) < eps_multiplier*eps(x) || return false
  end
  true
end

@doc """
Check that the matrices along the third axis are square and column-stochastic.

# Arguments

* `A::AbstractMatrix`: Column-stochastic square matrices.

# Returns

`true` if A is square and column-stochastic, `false` otherwise.

""" ->
function is_square_stochastic{T}(A::AbstractArray{T,3})
  for k = 1:size(A)[3]
    is_square_stochastic(A[:, :, k]) || return false
  end
  true
end

function ismdp{P<:FloatingPoint,R<:Real}(transition::AbstractArray{P,3}, reward::AbstractArray{R,1})
    # number of rows, columns and actions according to the transition
    # probability matrix
    ST = size(transition)[1]
    # number of states according to reward vector
    SR = length(reward)
    # number of transition states must equal number of reward states
    return (ST == SR) && is_square_stochastic(transition)
end

function ismdp{P<:FloatingPoint,R<:Real}(transition::AbstractArray{P,3}, reward::AbstractArray{R,2})
    ST, AT = size(transition)[[1, 3]]
    SR, AR = size(reward)
    return (ST == SR) && (AT == AR) && is_square_stochastic(transition)
end

function ismdp{P<:FloatingPoint,R<:Real}(transition::AbstractArray{P,3}, reward::AbstractArray{R,3})
    S1T, S2T, AT = size(transition)
    S1R, S2R, AR = size(reward)
    return (S1T == S1R) && (S2T == S2R) && (AT == AR) && is_square_stochastic(transition)
end
