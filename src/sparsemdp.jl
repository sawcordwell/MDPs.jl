
type SparseMDP{P<:FloatingPoint,Pi<:Integer,R<:Real} <: AbstractMDP{P,R}
    transition::Array{SparseMatrixCSC{P,Pi},1}
    reward::Array{P,2}
    policy::Array{Uint8,1}
    value::Array{P,1}
    S::Int
    A::Uint8
end

