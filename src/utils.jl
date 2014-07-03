
function is_square_stochastic{T<:FloatingPoint}(A::AbstractArray{T})
    r, c = size(A)[1:2]
    return (r == c) && all(abs(sum(A, 2) .- 1) .<= 10eps(T))
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

