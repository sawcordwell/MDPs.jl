
type CscMDP{P,Pi,R,V<:FloatingPoint} <: SparseMDP{P,Pi,R}
  transition::Array{SparseMatrixCSC{P,Pi},1}
  reward::Array{R,2}
  q::Array{V,2}
  n_states::Int
  n_actions::Int
end

type CscRewardMDP{P,Pi,R,Ri<:Integer,V<:FloatingPoint} <: SparseMDP{P,Pi,R}
  transition::Array{SparseMatrixCSC{P,Pi},1}
  reward::Array{SparseMatrixCSC{R,Ri},1}
  q::Array{V,2}
  n_states::Int
  n_actions::Int
end
