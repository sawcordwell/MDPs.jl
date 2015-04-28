
facts("Reward types") do
    @fact AbstractArrayReward <: AbstractReward => true
    @fact ArrayReward <: AbstractArrayReward => true
    @fact SparseReward <: AbstractArrayReward => true
end

facts("ArrayReward construction") do
    @fact typeof(Reward(rand(5))) => ArrayReward{Float64,1}
    @fact typeof(Reward(rand(5, 3))) => ArrayReward{Float64,2}
    @fact typeof(Reward(rand(5, 5, 3))) => ArrayReward{Float64,3}
    @fact_throws ErrorException Reward(rand(5, 4, 3))
    @fact typeof(Reward(sprand(5, 3, 1/3))) => SparseReward{Float64,Int}
end

facts("1d ArrayReward methods") do
    R = ArrayReward([1, 3, 1, 1, 2])
    @fact R[2] => 3
    @fact reward(R, 2) => 3
    @fact reward(R, 2, 3) => 3
    @fact reward(R, 2, 1, 3) => 3
    @fact_throws BoundsError R[2, 3]
    @fact_throws BoundsError R[2, 1, 3]
    @fact num_states(R) => 5
    @fact_throws ErrorException num_actions(R)
end

facts("2d ArrayReward methods") do
    R = ArrayReward([1 2 3; 2 3 1; 3 1 2; 2 1 3; 1 3 2])
    @fact R[2, 3] => 1
    @fact reward(R, 2, 3) => 1
    @fact reward(R, 2, 1, 3) => 1
    @fact_throws BoundsError R[2, 1, 3]
    @fact_throws MethodError reward(R, 2)
    @fact num_states(R) => 5
    @fact num_actions(R) => 3
end

facts("3d ArrayReward methods") do
    R = ArrayReward(
        cat(
            3,
            [1 2 3; 2 3 1; 3 1 2],
            [2 3 1; 3 1 2; 2 1 3],
        )
    )
    @fact R[2, 3, 2] => 2
    @fact reward(R, 2, 3, 2) => 2
    @fact num_states(R) => 3
    @fact num_actions(R) => 2
    @fact_throws MethodError reward(R, 2, 3)
    @fact_throws MethodError reward(R, 2)
end

facts("SparseReward methods") do
    R = SparseReward(sparse([1, 2, 3, 4, 5], [1, 2, 3, 2, 1], [1, 3, 1, 1, 2]))
    @fact R[2, 2] => 3
    @fact R[2, 1] => 0
    @fact reward(R, 2, 2) => 3
    @fact reward(R, 2, 1) => 0
    @fact reward(R, 2, 1, 2) => 3
    @fact num_states(R) => 5
    @fact num_actions(R) => 3
    @fact_throws MethodError reward(R, 2)
    @fact_throws BoundsError R[2, 1, 2]
end
