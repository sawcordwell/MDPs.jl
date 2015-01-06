# #define Abs(x)    ((x) < 0 ? -(x) : (x))
# #define Max(a, b) ((a) > (b) ? (a) : (b))

# double RelDif(double a, double b)
# {
# 	double c = Abs(a);
# 	double d = Abs(b);

# 	d = Max(c, d);

# 	return d == 0.0 ? 0.0 : Abs(a - b) / d;
# }
# Typical usage is
# 	if(RelDif(a, b) <= TOLERANCE) ...

using Base.Test

P = rand(Float64, 1000, 1000, 3);
P = P ./ sum(P, 1);

function test1{T<:FloatingPoint}(A::AbstractArray{T})
  r, c = size(A)[1:2]
  return (r == c) && all(abs(sum(A, 1) .- one(T)) .< 10eps(T))
end
@test test1(P)

function test2{T<:FloatingPoint}(A::AbstractArray{T})
  r, c = size(A)[1:2]
  ϵ = convert(T, 10)*eps(T)
  return (r == c) && all([abs(x - one(T)) < ϵ for x = sum(A, 1)])
end
@test test2(P)

function test2b{T<:FloatingPoint}(A::AbstractArray{T})
  r, c = size(A)[1:2]
  X = sum(A, 1)
  return (r == c) && all([abs(x - one(T)) < 5eps(max(x, one(T))) for x = X])
end
@test test2b(P)

function test3{T<:FloatingPoint}(A::AbstractArray{T})
  r, c = size(A)[1:2]
  ϵ = convert(T, 10)*eps(T)
  return (r == c) && all(Bool[abs(x - one(T)) < ϵ for x = sum(A, 1)])
end
@test test3(P)

function test4{T<:FloatingPoint}(A::AbstractArray{T})
  r, c = size(A)[1:2]
  ϵ = convert(T, 10)*eps(T)
  for x = sum(A, 1)
    abs(x - one(T)) < ϵ || return false
  end
  true
end
@test test4(P)

function test5{T<:FloatingPoint}(A::AbstractArray{T})
  r, c, d = size(A)
  r == c || return false
  ϵ = convert(T, 10)*eps(T)
  for k = 1:d
    for j = 1:c
      S = zero(T)
      @simd for i = 1:r
        @inbounds S += A[i, j, k]
      end
      abs(S - one(T)) < ϵ || return false
    end
  end
  true
end
@test test5(P)

function approx_equal_one{T}(x::T, max_rel_diff::T)
  oneT = one(T)
  diff = abs(x - oneT)
  x = abs(x)
  largest = (oneT > x) ? oneT : x
  diff <= largest * max_rel_diff || return false
  return true
end

function test6{T<:FloatingPoint}(A::AbstractArray{T})
  r, c, d = size(A)
  r == c || return false
  for k = 1:d
    for j = 1:c
      S = zero(T)
      @simd for i = 1:r
        @inbounds S += A[i, j, k]
      end
      approx_equal_one(S, 3eps(T)) || return false
    end
  end
  true
end
@test test6(P)

function test7{T<:FloatingPoint}(A::AbstractArray{T})
  r, c, d = size(A)
  r == c || return false
  for k = 1:d
    for j = 1:c
      S = zero(T)
      @simd for i = 1:r
        @inbounds S += A[i, j, k]
      end
      x = S < one(T) ? one(T) : S
      abs(S - one(T)) < 4eps(x) || return false
    end
  end
  true
end
@test test7(P)

# -------
# Timings
# -------

print("Test 1: ")
@time for i = 1:1000
  test1(P)
end

print("Test 2: ")
@time for i = 1:1000
  test2(P)
end

print("Test 2b: ")
@time for i = 1:1000
  test2b(P)
end

print("Test 3: ")
@time for i = 1:1000
  test3(P)
end

print("Test 4: ")
@time for i = 1:1000
  test4(P)
end

print("Test 5: ")
@time for i = 1:1000
  test5(P)
end

print("Test 6: ")
@time for i = 1:1000
  test6(P)
end

print("Test 7: ")
@time for i = 1:1000
  test6(P)
end
