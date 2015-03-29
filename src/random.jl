
rand_reward{R}(::Type{R}, dims...) = 1 .- 2*rand(R, dims...)


sum_columns_to_one(a::Array) = a ./ sum(a, 1)


# replace all elements of `a` with 0 where `mask` is `false`
function zero_mask!{T}(a::Array{T,3}, mask::AbstractArray{Bool,2})
    for k = 1:size(a)[3]
        setindex!(a[:, :, k], zero(T), find(!mask))
    end
end

zero_mask!{T}(a::Array{T,3}, mask::AbstractArray{Bool,3}) =
    setindex!(a, zero(T), find(!mask))


function random(states, actions, mask::AbstractArray{Bool})
    all(sum(mask,2) .> 0) ||
        error("All rows of mask must have at least one 'true' value.")
    size(mask) == (states, states) || size(mask) == (states, states, actions) ||
        error("Mask size must be `states`×`states` or `states`×`states`×`actions`.")
    transition = rand(states, states, actions)
    zero_mask!(transition, mask)
    transition = sum_columns_to_one(transition)
    reward = rand_reward(Float64, states, actions)
    (transition, reward)
end


function random{P<:FloatingPoint,R<:FloatingPoint}(
    ::Type{P},
    ::Type{R},
    states,
    actions,
)
    transition = rand(P, states, states, actions)
    transition = sum_columns_to_one(transition)
    reward = rand_reward(R, states, actions)
    (transition, reward)
end


random(states, actions) = random(Float64, Float64, states, actions)
