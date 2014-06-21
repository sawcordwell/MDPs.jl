
rowsumone{T<:FloatingPoint}(M::AbstractArray{T,2}) =
    all( abs( sum(M, 2) .- ones(T, size(M)[1]) ) .<= 2eps(T))

function is_square_stochastic{T<:FloatingPoint}(M::AbstractArray{T,2})
    r, c = size(M)
    return (r == c) && rowsumone(M)
end

function is_square_stochastic{T<:FloatingPoint}(A::AbstractArray{T,3})
    # number of rows (r), columns (c) and layers (l)
    r, c, l = size(A)
    # Check that the matrices are square (the number of columns equals the
    # number of rows)
    if r != c
        return false
    end
    # Check that each matrix is stochastic (all rows sum to one)
    for k in range(1, l)
        if !rowsumone(A[:, :, k])
            return false
        end
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
    ST1, ST2, AT = size(transition)
    SR1, SR2, AR = size(reward)
    return (ST1 == SR1) && (ST2 == SR2) && (AT == AR) && is_square_stochastic(transition)
end
