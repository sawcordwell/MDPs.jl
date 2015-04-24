
facts("Reward types") do
    @fact AbstractRewardArray <: AbstractReward => true
    @fact RewardArray <: AbstractRewardArray => true
    @fact RewardVector <: AbstractRewardArray => true
end

facts("Reward construction helper function") do
    @fact typeof(Reward(rand(5, 3))) => RewardArray{Float64}
    @fact typeof(Reward(rand(5))) => RewardVector{Float64}
end

facts("RewardArray construction") do
    @fact typeof(RewardArray(rand(5, 3))) => RewardArray{Float64}
    @fact_throws MethodError RewardArray(rand(5))
    @fact_throws MethodError RewardArray(rand(5, 5, 3))
end

facts("RewardArray methods") do
    R = RewardArray([1 2 3; 2 3 1; 3 1 2; 2 1 3; 1 3 2])
    @fact R[2, 3] => 1
    @fact reward(R, 2, 3) => 1
    @fact reward(R, 2, 1, 3) => 1
    @fact_throws BoundsError R[2, 1, 3]
    @fact_throws MethodError reward(R, 2)
end

facts("RewardVector construction") do
    @fact typeof(RewardVector(rand(5))) => RewardVector{Float64}
    @fact_throws MethodError RewardVector(rand(5, 3))
end

facts("RewardArray methods") do
    R = RewardVector([1, 3, 1, 1, 2])
    @fact R[2] => 3
    @fact reward(R, 2) => 3
    @fact reward(R, 2, 3) => 3
    @fact reward(R, 2, 1, 3) => 3
    @fact_throws BoundsError R[2, 3]
    @fact_throws BoundsError R[2, 1, 3]
end
