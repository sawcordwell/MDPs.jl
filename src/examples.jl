
function smallmdp()
  P = cat(3, [0.5 0.8; 0.5 0.2], [0 0.1; 1 0.9])
  R = [5 10; -1 2]
  (P, R)
end

function bellmanmachine(k::Int, M::Int, p::Array{Float64,2}, q::Array{Float64,2})
    #
end
