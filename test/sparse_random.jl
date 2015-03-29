
function sparse_random_factory(;
    states=10,
    state_type=Float64,
    actions=2,
    action_type=Float64,
)
    return MDPs.Examples.sprandom(state_type, action_type, states, actions)
end

"sparse randmdp should return a vector of sparse Float64 transition matrices"
let
    transition, reward = sparse_random_factory()
    @test typeof(transition) == Vector{SparseMatrixCSC{Float64,Int64}}
end

"sparse randmdp should return a sparse Float64 reward"
let
    transition, reward = sparse_random_factory()
    @test typeof(reward) == SparseMatrixCSC{Float64,Int64}
end

"sparse randmdp with Float32 types should return Float32 sparse matrices"
let
    transition, reward = sparse_random_factory(
        state_type=Float32,
        action_type=Float32,
    )
    @test typeof(transition) == Vector{SparseMatrixCSC{Float32,Int64}}
    @test typeof(reward) == SparseMatrixCSC{Float32,Int64}
end

"sparse randmdp transition matrix should be square"
let
    transition, reward = sparse_random_factory()
    rows, columns = size(transition[1])
    @test rows == columns
end

"sparse randmdp transition rows should sum to one"
let
    transition, reward = sparse_random_factory()
    @test_approx_eq sum(transition[1], 1) ones(size(transition[1])[1])
end

"sparse randmdp transition probabilities should be non-negative"
let
    transition, reward = sparse_random_factory()
    @test all(nonzeros(transition[1]) .>= 0)
end

"sparse randmdp transition matrices should be randomly generated"
let
    transition1, reward = sparse_random_factory()
    transition2, reward = sparse_random_factory()
    @test transition1[1] != transition2[1]
end
