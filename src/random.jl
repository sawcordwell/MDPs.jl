
rand_reward{T<:FloatingPoint}(::Type{T}, dims...) = 1 .- 2*rand(T, dims...)

rand_reward{T<:Integer}(::Type{T}, dims...) = rand(T, dims...)


sum_columns_to_one(a::Array) = a ./ sum(a, 1)


# replace all elements of `a` with 0 where `mask` is `false`
function zero_mask!{T}(a::AbstractArray{T,3}, mask::AbstractArray{Bool,2})
    all(sum(mask, 1) .> 0) ||
        error("All columns of mask must have at least one 'true' value.")
    size(mask) == size(a)[1:2] ||
        error("Mask size must be `states`×`states`.")
    for k = 1:size(a)[3]
        setindex!(sub(a, :, :, k), zero(T), find(!mask))
    end
end

function zero_mask!{T}(a::AbstractArray{T,3}, mask::AbstractArray{Bool,3})
    all(sum(mask, 1) .> 0) ||
        error("All columns of mask must have at least one 'true' value.")
    size(mask) == size(a) ||
        error("Mask size must be `states`×`states`×`actions`.")
    setindex!(a, zero(T), find(!mask))
end


function random{P<:FloatingPoint,R<:Real,N}(
    ::Type{P},
    ::Type{R},
    states,
    actions,
    mask::Nullable{Array{Bool,N}},
)
    transition = rand(P, states, states, actions)
    isnull(mask) ? nothing : zero_mask!(transition, get(mask))
    transition = sum_columns_to_one(transition)
    reward = rand_reward(R, states, actions)
    (transition, reward)
end

random{P,R}(::Type{P}, ::Type{R}, states, actions, mask::Array{Bool}) =
    random(P, R, states, actions, Nullable(mask))

random{P,R}(::Type{P}, ::Type{R}, states, actions) =
    random(P, R, states, actions, Nullable{Array{Bool,1}}())

random{N}(states, actions, mask::Nullable{Array{Bool,N}}) =
    random(Float64, Float64, states, actions, mask)

random(states, actions, mask::Array{Bool}) =
 random(states, actions, Nullable(mask))

random(states, actions) = random(states, actions, Nullable{Array{Bool,1}}())
