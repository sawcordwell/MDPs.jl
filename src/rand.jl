
function randmdp(s::Int, a::Int, mask::AbstractArray{Bool,3})
  @assert all(sum(mask,2) .> 0) "All rows of mask must have at least one 'true' value"
  @assert size(mask) == (s, s, a) "Mask must be s × s × a size"
  P = rand(s, s, a)
  # Replace all elements of ``P`` with 0 where mask is false
  setindex!(P, 0.0, find(!mask))
  # Make each column of ``P`` sum to 1
  P = P ./ sum(P, 1)
  # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
  R = 1 .- 2rand(s, a)
  (P, R)
end

function randmdp(s::Int, a::Int, mask::AbstractArray{Bool,2})
  @assert all(sum(mask,2) .> 0) "All rows of mask must have at least one 'true' value"
  @assert size(mask) == (s, s) "Mask must be s × a size"
  P = rand(s, s, a)
  # Replace all elements of ``P`` with 0 where mask is false
  for k = 1:a
    setindex!(P[:, :, k], 0.0, find(!mask))
  end
  # Make each column of ``P`` sum to 1
  P = P ./ sum(P, 1)
  # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
  R = 1 .- 2rand(s, a)
  (P, R)
end


function randmdp{P<:FloatingPoint,R<:FloatingPoint}(::Type{P}, ::Type{R}, s::Int, a::Int)
  transition = rand(P, s, s, a)
  # Make each row of ``P`` sum to 1
  transition = transition ./ sum(transition, 1)
  # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
  reward = 1 .- 2rand(R, s, a)
  (transition, reward)
end

randmdp(s::Int, a::Int) = randmdp(Float64, Float64, s, a)
