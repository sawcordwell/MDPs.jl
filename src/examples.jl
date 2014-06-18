
function randmdp(s::Int, a::Int)
    P = rand(s, s, a)
    for k in range(1, a)
        P[:, :, k] = P[:, :, k] ./ sum(P[:, :, k], 2)
    end
    R = 1 .- 2rand(s, a)
    (P, R)
end

#function randmdp(s::Real, a::Real, mask::Array{Bool,2})
#    #
#end

