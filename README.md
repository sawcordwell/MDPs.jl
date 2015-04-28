# MDPs

[![Build Status](https://travis-ci.org/sawcordwell/MDPs.jl.svg?branch=master)](https://travis-ci.org/sawcordwell/MDPs.jl)
[![Coverage Status](https://coveralls.io/repos/sawcordwell/MDPs.jl/badge.png?branch=master)](https://coveralls.io/r/sawcordwell/MDPs.jl?branch=master)

*MDPs* is a [Julia](http://www.julialang.org/) package for working with Markov
decision processes (MDPs).

## Installation

*MDPs* supports both Julia 0.3 and 0.4, and can be installed from the
REPL via:

```julia
Pkg.add("MDPs")
```

## Quick Use

So far only a few simple types and the value iteration algorithm have been implemented.
A basic usage could look like this:

```julia
using MDPs
P, R = MDPs.Examples.random(10, 3)  # a random MDP with 10 states and 3 actions
mdp = MDP(P, R)
Q = value_iteration(mdp, 0.9)  # value iteration with a discount factor of 0.9
value(Q)  # the optimal value vector
policy(Q)  # the optimal policy vector
```

## Documentation

The documentation is here for now until it becomes more complete.
For more information please check the docstrings and source code.

### Types

There are four categories of types:

* Transition probability
* Reward
* Q function
* MDP

In the following discussion,
let `S` be the number of states and `A` be the number of actions.

#### Transition probability types

A transition probability is the probability that
the system moves from state <var>s</var> to state <var>s'</var> given
that action <var>a</var> was taken.
So there must be some function `P`,
that takes input arguments `s`, `t` and `a`,
and maps these to an output `p`.
`p` is the probability that `s` transitions to `t` when `a` is performed.
The transition probability types are used to abstract this functionality.

The base type is `AbstractTransitionProbability`,
and types that implement transition probability functionality should be subtypes of it.
Any subtype of `AbstractTransitionProbability` is expected to implement a method called `probability`
The calling signature of this function looks like:

```julia
probability(P, s, t, a)
```

where `P` is a subtype of `AbstractTransitionProbability`,
`s` is the starting state,
`t` is the next state,
`a` is the action,
and it returns a `Real` between 0 and 1 inclusive.

Any algorithm should be designed to accept this abstract type and
interact with it using the `probability` function.

This absrtact type has two subtypes:
`AbstractTransitionProbabilityArray` and `MDPs.TransitionProbabilityFunction`.
`AbstractTransitionProbabilityArray` is the base type for transition probability types
that store data as a Julia `AbstractArray` subtype.
It has two concrete subtypes `TransitionProbabilityArray` and `SparseTransitionProbabilityArray`.
These types are constructed by passing the approprioate Julia array type:
either an `Array{T<:Real,3}` or `Vector{SparseMatrixCSC{Tv<:Real,Ti<:Integer}}` respectively.

These types all have a convenience constructor `TransitionProbability`
that will return the correct type based on the type of its argument.

For example,
these define a transition probabilities for five states and two actions,
where states always transition back to themselves:

```julia
P_dense = TransitionProbability(cat(3, eye(5), eye(5)))
P_sparse = TransitionProbability(SparseMatrixCSC{Float64,Int}[speye(5) for _ = 1:2])
probability(P_dense, 1, 1, 2) == probability(P_sparse, 1, 1, 2) == 1
probability(P_dense, 1, 2, 2) == probability(P_sparse, 1, 2, 2) == 0
```

The constructor for `FunctionTransitionProbability` takes a Julia `Function` and
the number of states and actions.
The function should accept three arguments `s`, `t`, `a` and return a `Real`.
For example:

```julia
P = TransitionProbability((s, t, a) -> s == t ? 1 : 0, 5, 2)
probability(P, 1, 1, 2)  == 1
probability(P, 1, 2, 2)  == 0
```

The benefit of using a function could be to define very large state or action spaces.
As an exagerated example:

```julia
s = BigInt(string(typemax(Int))^2)  # 92233720368547758079223372036854775807 on 64 bit
probability(P, s, s, 1000) == 1
```

#### Reward types

A reward is a score used to adjust the value that is assigned to each state in the long run.
The base type is `AbstractReward`, and rewards should be a subtype of this.

Each subtype should also define the `reward` method.
The calling signature is

```julia
reward(R, s, a)
```

where `R` is a subtype of `AbstractReward`,
`s` is the state,
`a` is the action,
and it returns a `Real`.

There is a subtype `AbstractArrayReward` with two further subtypes:
`ArrayReward` and `SparseReward`.
`ArrayReward` can be constructed with either a `Vector`, `Matrix` or `Array{T,3}`.
`SparseReward` is constructed with a `SparseMatrixCSC`.
There is a convenience function `Reward` which will return the appropriate type.
Examples with 10 states and 3 actions:

```julia
R1 = Reward(rand(10))  # reward depends only on state
R2 = Reward(rand(10, 3))
R3 = Reward(rand(10, 10, 3))
R4 = Reward(sprand(10, 3, 1/3))
```

The 3-dimensional `ArrayReward` is most useful for reinforcement learning algorithms.

#### Q-function types

The Q-function types abstract the process of assigning values to states and actions.
The base type is `AbstractQFunction`, and
there are currently two subtypes: `ArrayQFunction` and `VectorQFunction`.
`ArrayQFunction` stores a dense matrix of the value for each state-action pair.
On the other hand,
`VectorQFunction` stores only the currently optimal value and policy.
These two types represent different trade-offs for memory/time efficiency.
The methods that should be implemented for these types are
`valuetype(Q)`, `value(Q)`, `policy(Q)`, `value!(V, Q)`, and `setvalue!(Q, v, s, a)`,
where `Q` is a subtype of `AbstractQFunction`.

* `valuetype(Q)`: the type of the values
* `policy(Q)`: the optimal policy
* `value(Q)`: the value of each state when following the optimal policy
* `value!(V, Q)`: copy the value to `V`
* `setvalue!(Q, v, s, a)`: set the value of being in state `s` and taking action `a` to `v`

Examples for 10 states and 3 actions:

```julia
Q1 = ArrayQFunction(10, 3)  # initialised to Float64 zeros
Q2 = ArrayQFunction(rand(10, 3))  # pass in pre-initialised array
Q3 = QFunction(rand(10, 3))  # identical to previous
Q4 = VectorQFunction(10)  # initialised to Float64 zeros
Q5 = VectorQFunction(rand(10), rand(Int, 10))  # pass in pre-initialised vectors
Q6 = QFunction(rand(10), rand(Int, 10))  # identical to previous
```

#### MDP types

The base type if `AbstractMDP` with one concrete subtype `MDP`.
`POMDP` is planned for the future.

The MDP types provide a wrapper around `AbstractTransitionProbability` and `AbstractReward` types,
ensure that the number of states and actions in both are the same,
and that the transition probability matrices are square and stochastic.
They are initialised by passing an `AbstractTransitionProbability` and `AbsrtactReward`.

Also algorithms take an `AbstractQFunction` instance and an `AbstractMDP` instance to solve the problem.

Currently there are `value_iteration(mdp::MDP, δ)` and `value_iteration!(Q::AbsrtactQFunction, mdp::MDP, δ)` defined.
These perform the value iteration algorithm.
The former will construct its own Q-function and return it,
while the later will modify the Q-function that is passed to it.

### Other functions

This is a list of the other exported functions:

* `bellman`: the Bellman operator.
* `bellman!`: the in-place Bellman operator.
* `is_square_stochastic`: checks that `P` is square-stochastic.
* `ismdp`: checks that `P` and `R` describe a valid MDP.
* `num_actions`: number of states.
* `num_states`: number of actions.

### Examples

There are some examples in the `Examples` submodule that
return transition and reward types, which
can be passed to the `TransitionProbability` and `Reward` methods respectively. 

* `MDPs.Examples.random`: random dense
* `MDPs.Examples.sprandom`: random sparse
* `MDPs.Examples.small`: two states and two actions

#### `MDPs.Examples.random`

`MDPs.Examples.random(states, actions)` will create a random Float64 transition
array that is of size `states`×`states`×`actions` and a random Float64 reward
array that is of size `states`×`actions`.

`MDPs.Examples.random{N}(states, actions, mask::Array{Bool,N})` will set the
transition array to zero everywhere that mask is `false`. `mask` can be
`states`×`states`×`actions` or `states`×`actions` in size.

### References

Bellman R, 1957, [A Markovian Decision Process](http://www.iumj.indiana.edu/IUMJ/FULLTEXT/1957/6/56038), _Journal of Mathematics and Mechanics_, vol. 6, no. 5, pp. 679–684.

## Support

Please file and issues or feature requests through the GitHub
[issue tracker](https://github.com/sawcordwell/MDPs.jl/issues).

## License

The package is licensed under the terms of the MIT "Expat" License. See
[LICENSE.md](LICENSE.md) for details.
