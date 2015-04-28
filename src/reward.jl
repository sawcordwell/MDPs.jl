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

abstract AbstractArrayReward <: AbstractReward


getindex(R::AbstractArrayReward, dims...) = getindex(R.array, dims...)

size(R::AbstractArrayReward, d) = size(R.array, d)


num_states(R::AbstractArrayReward) = size(R, 1)


# ----------
# Array type
# ----------

immutable ArrayReward{T<:Real,N} <: AbstractArrayReward
    array::Array{T,N}

    function ArrayReward(array::Array{T,N})
        N < 3 || (N == 3 && size(array, 1) == size(array, 2)) ||
            error("ArrayReward can not constructed with this Array.")
        new(array)
    end
end

ArrayReward{T,N}(array::Array{T,N}) = ArrayReward{T,N}(array)


# type construction helper
Reward(A::Array) = ArrayReward(A)


num_actions{T}(R::ArrayReward{T,1}) =
    error(string(typeof(R))*" does not know about actions.")
num_actions{T,N}(R::ArrayReward{T,N}) = size(R, N)


# 1 dimension
# -----------

reward{T}(R::ArrayReward{T,1}, state) = getindex(R, state)

reward{T}(R::ArrayReward{T,1}, state, action) = reward(R, state)

reward{T}(R::ArrayReward{T,1}, state, new_state, action) = reward(R, state)


# 2 dimensions
# ------------

reward{T}(R::ArrayReward{T,2}, state, action) = getindex(R, state, action)

reward{T}(R::ArrayReward{T,2}, state, new_state, action) = reward(R, state, action)

# 3 dimensions
# ------------

reward{T}(R::ArrayReward{T,3}, state, new_state, action) =
    getindex(R, state, new_state, action)



# -----------
# Sparse type
# -----------

immutable SparseReward{Tv<:Real,Ti} <: AbstractArrayReward
    array::SparseMatrixCSC{Tv,Ti}
end


Reward(A::SparseMatrixCSC) = SparseReward(A)


num_actions(R::SparseReward) = size(R, 2)


reward(R::SparseReward, state, action) = getindex(R, state, action)

reward(R::SparseReward, state, new_state, action) = reward(R, state, action)
