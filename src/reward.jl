# --------------
# Abstract types
# --------------

@doc """
# Interface

* reward(R, s, a)

## Optional

* reward(R, s, s, a)
* reward(R, s)

""" ->
abstract AbstractReward

abstract AbstractRewardArray <: AbstractReward


getindex(R::AbstractRewardArray, dims...) = getindex(R.array, dims...)



# ----------
# Array type
# ----------

immutable RewardArray{T<:Real} <: AbstractRewardArray
    array::Matrix{T}
end


# type construction helper
Reward(A::Matrix) = RewardArray(A)


reward(R::RewardArray, state, action) = getindex(R, state, action)

reward(R::RewardArray, state, new_state, action) = reward(R, state, action)



# -----------
# Vector type
# -----------

immutable RewardVector{T<:Real} <: AbstractRewardArray
    array::Vector{T}
end


# type construction helper
Reward(A::Vector) = RewardVector(A)


reward(R::RewardVector, state) = getindex(R, state)

reward(R::RewardVector, state, action) = reward(R, state)

reward(R::RewardVector, state, new_state, action) = reward(R, state)
