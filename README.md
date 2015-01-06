# MDPs

[![Build Status](https://travis-ci.org/sawcordwell/MDPs.jl.svg?branch=master)](https://travis-ci.org/sawcordwell/MDPs.jl)
[![Coverage Status](https://coveralls.io/repos/sawcordwell/MDPs.jl/badge.png)](https://coveralls.io/r/sawcordwell/MDPs.jl)

*MDPs* is a [Julia](www.julialang.org) package for working with Markov
decision processes (MDPs).

## Installation

*MDPs* supports both Julia 0.3 and 0.4, and can be installed from the
REPL via:

```julia
Pkg.add("https://github.com/sawcordwell/MDPs.jl.git")
```

## Quick Use

So far only an MDP type, the Bellman operator and a few support
functions are implemented:

```julia
using MDPs
P, R = randmdp(10, 3)
mdp = MDP(P, R)
bellman!(mdp, 0.9)
```

## Documentation

The documentation is here for now until it becomes more complete.

### Types

There are currently three types:

* `AbstractMDP` - the abstract base type for all MDP types.
* `MDP` - the default dense MDP type.
* `QMDP` - a dense MDP type that stores the full state-action value function.

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
about `1.1102230246251565e-15` of `1.0` when using `Float64` or
`5.9604645f-7` when using `Float32` values. This may be too strict for
some purposes, so please file an issue is this is affecting you.

`R` is the array of reward vectors. It can either be a one-dimensional
vector or a two-dimensional array. If it is a vector it must be of
length `S`, and if it is two dimensional it must be `S`×`A` as stated
above.

### Functions

These are the current functions:

* `bellman` - the Bellman operator.
* `bellman!` - the in-place Bellman operator.
* `is_square_stochastic` - checks that `P` is sqaure-stochastic.
* `ismdp` - checks that `P` and `R` describe a valid MDP
* `policy` - gets the current policy from the MDP
* `randmdp` - generates a random `P` and `R` that is a valid MDP
* `reset!` - resets an MDP to its original state
* `smallmdp` - generates a small example for `P` and `R`
* `value` - gets the value vector of the MDP

For more information please check the docstrings and source code for now.

## Support

Please file and issues or feature requests through the GitHub
[issue tracker](https://github.com/MichaelHatherly/Docile.jl/issues).

## License

The package is licensed under the terms of the MIT "Expat" License. See
[LICENSE.md](LICENSE.md) for details.
