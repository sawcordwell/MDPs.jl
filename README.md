# MDPs

[![Build Status](https://travis-ci.org/sawcordwell/MDPs.jl.svg?branch=master)](https://travis-ci.org/sawcordwell/MDPs.jl)
[![Coverage Status](https://coveralls.io/repos/sawcordwell/MDPs.jl/badge.png?branch=master)](https://coveralls.io/r/sawcordwell/MDPs.jl?branch=master)

*MDPs* is a [Julia](www.julialang.org) package for working with Markov
decision processes (MDPs).

## Installation

*MDPs* supports both Julia 0.3 and 0.4, and can be installed from the
REPL via:

```julia
Pkg.add("MDPs")
```

## Quick Use

So far only a dense MDP type and the value iteration algorithm have been implemented.
A basic usage could look like this:

```julia
using MDPs
P, R = randmdp(10, 3) # A random MDP with 10 states and 3 actions
mdp = MDP(P, R)
value_iteration!(mdp, 0.9)
policy(mdp)
```

## Documentation

The documentation is here for now until it becomes more complete.

### Types

There are currently four types:

* `AbstractMDP`: the abstract base type for all MDP types.
* `DenseMDP`: the base abstract type for dense MDPs.
* `MDP`: the default dense MDP type.
* `QMDP`: a dense MDP type that stores the full state-action value function.

Let `S` be the number of states in the MDP and `A` be the number of
actions, then the easiest way to construct the `MDP` or `QMDP` type is
to pass it two arrays `P` and `R`. The size of `P` must be `S`×`S`×`A`
and the size of `R` must be `S`×`A`.

```julia
mdp = MDP(P, R)
```

`P` is the array of transition probability matrices. `P` must be a
three-dimensional array, where the third dimension indexes the
transition probability matrices for each action. Each transition
probability matrix of `P` must be square and column-stochastic, which
means that the number of rows equals the number of columns and that each
column must sum to one. Specifically they currently should sum to within
about `2.220446049250313e-15` of `1.0` when using `Float64` or
`1.1920929f-6` when using `Float32` values. This may be too strict for
some purposes, so please file an issue is this is affecting you.

`R` is the array of reward vectors. It can either be a one-dimensional
vector or a two-dimensional array. If it is a vector it must be of
length `S`, and if it is two dimensional it must be `S`×`A` as stated
above.

### Functions

These are the current functions:

* `bellman`: the Bellman operator.
* `bellman!`: the in-place Bellman operator.
* `is_square_stochastic`: checks that `P` is sqaure-stochastic.
* `ismdp`: checks that `P` and `R` describe a valid MDP.
* `policy`: gets the current policy from the MDP.
* `randmdp`: generates a random `P` and `R` that is a valid MDP.
* `reset!`: resets an MDP to its original state.
* `smallmdp`: generates a small example for `P` and `R`.
* `value`: gets the value vector of the MDP.
* `value_iteration!`: the value iteration algorithm.

For more information please check the docstrings and source code for now.

### References

Bellman R, 1957, [A Markovian Decision Process](http://www.iumj.indiana.edu/IUMJ/FULLTEXT/1957/6/56038), _Journal of Mathematics and Mechanics_, vol. 6, no. 5, pp. 679–684.

## Support

Please file and issues or feature requests through the GitHub
[issue tracker](https://github.com/MichaelHatherly/Docile.jl/issues).

## License

The package is licensed under the terms of the MIT "Expat" License. See
[LICENSE.md](LICENSE.md) for details.
