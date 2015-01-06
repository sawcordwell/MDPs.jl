using Base.Test

using MDPs

function test1{P,R}(::Type{P}, ::Type{R}, s::Int, a::Int)
  transition = rand(P, s, s, a)
  # Make each row of ``P`` sum to 1
  transition = transition ./ sum(transition, 1)
  # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
  reward = one(R) .- 2rand(R, s, a)
  (transition, reward)
end
for T in (Float32, Float64)
  P, R = test1(T, T, 100, 3)
  @test is_square_stochastic(P)
end

function test2{P,R}(::Type{P}, ::Type{R}, s::Int, a::Int)
  transition = rand(P, s, s, a)
  # Make each row of ``P`` sum to 1
  for k = 1:a
    for j = 1:s
      S = zero(P)
      @simd for i = 1:s
        @inbounds S += transition[i, j, k]
      end
      @simd for i = 1:s
        @inbounds transition[i, j, k] /= S
      end
    end
  end
  # Generate ``a`` vectors of lenth ``s`` of rewards between -1 and 1
  reward = one(R) .- 2rand(R, s, a)
  (transition, reward)
end
for T in (Float32, Float64)
  P, R = test2(T, T, 100, 3)
  @test is_square_stochastic(P)
end

function test3{P,R}(::Type{P}, ::Type{R}, s::Int, a::Int)
  transition = rand(P, s, s, a)
  reward = rand(R, s, a)
  for k = 1:a
    for j = 1:s
      S = zero(P)
      @simd for i = 1:s
        @inbounds S += transition[i, j, k]
      end
      @simd for i = 1:s
        @inbounds transition[i, j, k] /= S
      end
      @inbounds reward[j, k] = one(R) - 2reward[j, k]
    end
  end
  (transition, reward)
end
for T in (Float32, Float64)
  P, R = test3(T, T, 100, 3)
  @test is_square_stochastic(P)
end

function test4{P,R}(::Type{P}, ::Type{R}, s::Int, a::Int)
  transition = Array(P, s, s, a)
  reward = Array(R, s, a)
  for k = 1:a
    for j = 1:s
      S = zero(P)
      @simd for i = 1:s
        r = rand(P)
        @inbounds transition[i, j, k] = r
        S += r
      end
      @simd for i = 1:s
        @inbounds transition[i, j, k] /= S
      end
      @inbounds reward[j, k] = one(R) - convert(R, 2)*rand(R)
    end
  end
  (transition, reward)
end
for T in (Float32, Float64)
  P, R = test4(T, T, 100, 3)
  @test is_square_stochastic(P)
end

print("Test 1: ")
@time for x = 1:10000
  test1(Float64, Float64, 100, 3)
end

print("Test 2: ")
@time for x = 1:10000
  test2(Float64, Float64, 100, 3)
end

print("Test 3: ")
@time for x = 1:10000
  test3(Float64, Float64, 100, 3)
end

print("Test 4: ")
@time for x = 1:10000
  test4(Float64, Float64, 100, 3)
end
