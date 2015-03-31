
"mask with all false columns should produce an error"
let
    mask = transpose([false false false; true false true; false true false])
    @test_throws ErrorException MDPs.Examples.random(size(mask, 1), 2, mask)
end

"mask sizes that do not match the states and actions arguments should throw error"
let
    mask = transpose([true false false; true false true; false true false])
    @test_throws ErrorException MDPs.Examples.random(size(mask, 1) + 1, 2, mask)
end

"random transition with a 2d mask argument should have zeros everywhere the mask is false"
let
    mask = transpose([true false false; true false true; false true false])
    transition, reward = MDPs.Examples.random(3, 2, mask)
    @test (transition[:, :, 2] .!= 0.0) == mask
    @test (transition[:, :, 2] .!= 0.0) == mask
end

"random transition with a 3d mask argument should have zeros everywhere the mask is false"
let
    mask = [x==y for x in 1:3, y in 1:3, z in 1:2]
    transition, reward = MDPs.Examples.random(3, 2, mask)
    @test (transition .!= 0.0) == mask
end

"random should accept a Nullable{Array{Bool}} as a mask and the "
"returned array types should be Float64"
let
    transition, reward = MDPs.Examples.random(
        10,
        2,
        Nullable{Array{Bool,2}}(),
    )
    @test typeof(transition) == Array{Float64,3}
    @test typeof(reward) == Array{Float64,2}
end

"random with just two numbers should word and return Float64 arrays"
let
    transition, reward = MDPs.Examples.random(10, 2)
    @test typeof(transition) == Array{Float64,3}
    @test typeof(reward) == Array{Float64,2}
end

"random with different types for transition and reward should return arrays of those types"
let
    transition, reward = MDPs.Examples.random(Float64, Float32, 10, 2)
    @test typeof(transition) == Array{Float64,3}
    @test typeof(reward) == Array{Float32,2}
end

"random should allow Integer reward types"
let
    transition, reward = MDPs.Examples.random(Float64, Int8, 10, 2)
    @test typeof(transition) == Array{Float64,3}
    @test typeof(reward) == Array{Int8,2}
end
