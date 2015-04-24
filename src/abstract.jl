
abstract AbstractMDP

abstract DenseMDP{P<:FloatingPoint,R<:Real} <: AbstractMDP

abstract
  SparseMDP{P<:FloatingPoint,Pi<:Integer,R<:Real} <:
  AbstractMDP

@doc """
# Interface

where Q is a subtype of AbstractQFunction

* policy(Q) -> a vector of the (currently) optimal policy for all states
* policy(Q, s) -> the (currently) optimal action to take at state s
* value(Q) -> a vector of the currently optimal values for all states
* value(Q, s) -> the value expected from state s given (currently) optimal actions are taken
* setvalue!(Q, v, s, a) -> set the value for state action
* num_states(Q) -> the number of states

## Optional

* getvalue(Q, s, a) -> the value expected from state s given action a is taken
* num_actions(Q) -> the number of actions

""" ->
abstract AbstractQFunction
