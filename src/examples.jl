
function randmdp(s::Int, a::Int)
    P = rand(s, s, a)
    for k = 1:a
        P[:, :, k] = P[:, :, k] ./ sum(P[:, :, k], 2)
    end
    R = 1 .- 2rand(s, a)
    (P, R)
end

function randmdp(s::Real, a::Real, mask::Array{Bool,2})
    P = rand(s, s, a)
    for k = 1:a
        P[:, :, k][!mask] = 0
        P[:, :, k] = P[:, :, k] ./ sum(P[:, :, k], 2)
    end
    R = 1 .- 2rand(s, a)
    (P, R)
end

function bellmanmachine(k::Int, M::Int, p::Array{Float64,2}, q::Array{Float64,2})
    #
end
