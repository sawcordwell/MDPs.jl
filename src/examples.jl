
function randmdp(s::Integer, a::Integer, mask::AbstractArray{Bool,3})
    @assert all(sum(mask,2) .> 0) "All rows of mask must have at least one 'true' value"
    @assert size(mask) == (s, s, a) "Mask must be s × s × a size"
    P = rand(s, s, a)
    # Replace all elements of ``P`` with 0 where mask is false
    setindex!(P, 0.0, find(!mask))
    # Make each row of ``P`` sum to 1
    P = P ./ sum(P, 2)
    # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
    R = 1 .- 2rand(s, a)
    (P, R)
end

randmdp(s::Integer, a::Integer, mask::AbstractArray{Bool,2}) =
    randmdp(s, a, reshape(repmat(mask, 1, a), (s, s, a)))

function randmdp(s::Integer, a::Integer)
    # FIXME: This is a hack to prevent the mask from having any rows that do
    # not have at least one true element.
    mask = randbool(s, s, a)
    while any(sum(mask, 2) .== 0)
        mask = randbool(s, s, a)
    end
    # TODO: A better way may be to just generate the mask once, find the rows
    # that contain only false elements, and put in some true ones
    #rowsums = (sum(mask, 2) .== 0)
    #if any(rowsums)
    #    for k in find(rowsums)
    #       # Put in true values here
    #    end
    #end
    randmdp(s, a, mask)
end

function bellmanmachine(k::Int, M::Int, p::Array{Float64,2}, q::Array{Float64,2})
    #
end
