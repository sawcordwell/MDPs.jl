
abstract AbstractMDP

abstract DenseMDP{P<:FloatingPoint,R<:Real} <: AbstractMDP

abstract
  SparseMDP{P<:FloatingPoint,Pi<:Integer,R<:Real} <:
  AbstractMDP
