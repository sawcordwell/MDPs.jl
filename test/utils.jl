facts("is_square_stochastic with sparse transition") do
    @fact is_square_stochastic(speye(10)) => true
    @fact is_square_stochastic([ speye(10) for _ = 1:3 ]) => true
    @fact is_square_stochastic([ 2*speye(10) for _ = 1:3 ]) => false
end

facts("square stochastic with Int transition") do
    @fact is_square_stochastic(eye(Int, 10)) => true
    @fact is_square_stochastic(2*eye(Int, 10)) => false
end

facts("ismdp with dense transition and vector reward") do
    P = cat(3, eye(10), eye(10))
    @fact ismdp(P, rand(10)) => true
    @fact ismdp(P, rand(11)) => false
end

facts("ismdp with dense transition and array reward") do
    P = cat(3, eye(10), eye(10))
    @fact ismdp(P, rand(10, 10, 2)) => true
    @fact ismdp(P, rand(10, 11, 2)) => false
    @fact ismdp(P, rand(9, 10, 2)) => false
    @fact ismdp(P, rand(10, 10, 3)) => false
end

facts("ismdp with sparse transition and reward") do
    P = [ speye(10) for _ = 1:3 ]
    R = sprand(10, 3, 1/3)
    @fact ismdp(P, R) => true
    P = SparseMatrixCSC[ speye(10), speye(11), speye(10) ]
    R = sprand(10, 3, 1/3)
    @fact ismdp(P, R) => false
    P = [ speye(10) for _ = 1:2 ]
    R = sprand(10, 3, 1/3)
    @fact ismdp(P, R) => false
end

facts("ismdp with sparse transition and dense reward") do
    P = [ speye(10) for _ = 1:3 ]
    @fact ismdp(P, rand(10)) => true
    @fact ismdp(P, rand(11)) => false
    @fact ismdp(P, rand(10, 3)) => true
    @fact ismdp(P, rand(11, 3)) => false
    @fact ismdp(P, rand(11, 4)) => false
    @fact ismdp(P, rand(10, 10, 3)) => true
    @fact ismdp(P, rand(10, 11, 3)) => false
    @fact ismdp(P, rand(11, 10, 3)) => false
    @fact ismdp(P, rand(10, 10, 2)) => false
end

facts("ismdp with dense transition and sparse reward") do
    P = cat(3, eye(10), eye(10), eye(10))
    @fact ismdp(P, sprand(10, 3, 1/3)) => true
    @fact ismdp(P, sprand(11, 3, 1/3)) => false
    @fact ismdp(P, sprand(10, 4, 1/3)) => false
end

facts("ismdp with transition probability and reward types") do
    P = TransitionProbability(cat(3, eye(10), eye(10)))
    R = Reward(rand(10, 2))
    @fact ismdp(P, R) => true
end

facts("ismdp with MDP type") do
    P, R = MDPs.Examples.small()
    @fact ismdp(MDP(P, R)) => true
end
