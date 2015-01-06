
using Base.Test
S = 1000
# Rows of Tr should sum to one
Tr = rand(S, S, 3);
Tr = Tr ./ sum(Tr, 2);
@test_approx_eq sum(Tr, 2) ones(size(Tr)[2:3])
# Columns of Tc should sum to one
Tc = similar(Tr);
for k = 1:3
  Tc[:, :, k] = Tr[:, :, k]';
end
@test_approx_eq sum(Tc, 1) ones(size(Tc)[2:3])

R = rand(S, 3);
Q = zeros(R);
V = zeros(S);

function bellman1(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  for a = 1:size(t)[3]
    q[:, a] = r[:, a] + d * (t[:, :, a] * v)
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman2(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  for a = 1:size(t)[3]
    for s = 1:size(t)[1]
      q[s, a] = (r[s, a] + d * (t[s, :, a] * v))[1]
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman3(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  for a = 1:size(t)[3]
    for s = 1:size(t)[1]
      q[s, a] = (r[s, a] + d * (v' * t[:, s, a]))[1]
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman4(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  s1, s2, a = size(t)
  @assert length(v) == s1
  @assert size(r) == (s2, a)
  @assert size(q) == (s2, a)
  @inbounds for k = 1:a
    for j = 1:s2
      S = 0.0
      @simd for i = 1:s1
        S += t[i, j, k] * v[i]
      end
      q[j, k] = r[j, k] + d * S
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman5(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  for a = 1:size(t)[3]
    for s1 = 1:size(t)[1]
      S = 0.0
      for s2 = 1:size(t)[1]
        S += t[s2, s1, a] * v[s2]
      end
      q[s1, a] = r[s1, a] + d * S
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman6(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  s1, s2, a = size(t)
  @assert length(v) == s1
  @assert size(r) == (s2, a)
  @assert size(q) == (s2, a)
  @inbounds for k = 1:a
    for i = 1:s2
      S = 0.0
      @simd for j = 1:s1
        S += t[i, j, k] * v[j]
      end
      q[i, k] = r[i, k] + d * S
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman7(newv::Vector, v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, d::Float64, policy::Vector{Int})
  s1, s2, a = size(t)
  @assert length(v) == length(newv) == s1
  @assert size(r) == (s2, a)
  copy!(newv, v)
  @inbounds for k = 1:a
    for j = 1:s2
      S = 0.0
      @simd for i = 1:s1
        S += t[i, j, k] * v[i]
      end
      q = r[j, k] + d * S
      if newv[j] < q
        newv[j] = q
        policy[j] = k
      end
    end
  end
end

function bellman7b(newv::Vector, v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, d::Float64, policy::Vector{Int})
  s1, s2, a = size(t)
  @assert length(v) == length(newv) == s1
  @assert size(r) == (s2, a)
  @inbounds begin
    for i = 1:s2
      newv[i] = v[i]
    end
    for k = 1:a
      for j = 1:s2
        S = 0.0
        @simd for i = 1:s1
          S += t[i, j, k] * v[i]
        end
        q = r[j, k] + d * S
        if newv[j] < q
          newv[j] = q
          policy[j] = k
        end
      end
    end
  end
end

function bellman8(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  for a = 1:size(t)[3]
    tv = t[:, :, a] * v
    q[:, a] = r[:, a] + d * tv
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

function bellman9(v::Vector{Float64}, t::Array{Float64,3},
                  r::Matrix{Float64}, q::Matrix{Float64}, d::Float64)
  s1, s2, a = size(t)
  @assert length(v) == s1
  @assert size(r) == (s1, a)
  @assert size(q) == (s1, a)
  @inbounds for a = 1:size(t)[3]
    tv = t[:, :, a] * v
    @simd for i = 1:s1
      q[i, a] = r[i, a] + d * tv[i]
    end
  end
  [maximum(q[r, :]) for r = 1:size(t)[1]]
end

V1 = bellman1(V, Tr, R, Q, 0.9);
P1 = [indmax(Q[s, :]) for s = 1:size(Tr)[1]];

V2 = bellman2(V, Tr, R, Q, 0.9);
P2 = [indmax(Q[s, :]) for s = 1:size(Tr)[1]];
@test_approx_eq V1  V2
@assert P1 == P2

V3 = bellman3(V, Tc, R, Q, 0.9);
P3 = [indmax(Q[s, :]) for s = 1:size(Tr)[1]];
@test_approx_eq V1  V3
@assert P1 == P3

V4 = bellman4(V, Tc, R, Q, 0.9);
P4 = [indmax(Q[s, :]) for s = 1:size(Tc)[1]];
@test_approx_eq V1  V4
@assert P1 == P4

V5 = bellman5(V, Tc, R, Q, 0.9);
P5 = [indmax(Q[s, :]) for s = 1:size(Tc)[1]];
@test_approx_eq V1  V5
@assert P1 == P5

V6 = bellman6(V, Tr, R, Q, 0.9);
P6 = [indmax(Q[s, :]) for s = 1:size(Tr)[1]];
@test_approx_eq V1  V6
@assert P1 == P6

V7new = similar(V)
V7old = copy(V)
P7 = ones(Int, S)
bellman7(V7new, V7old, Tc, R, 0.9, P7);
@test_approx_eq V1 V7new
@assert P1 == P7

V7bnew = similar(V)
V7bold = copy(V)
P7b = ones(Int, S)
bellman7b(V7bnew, V7bold, Tc, R, 0.9, P7b);
@test_approx_eq V1 V7bnew
@assert P1 == P7b

V8 = bellman8(V, Tr, R, Q, 0.9);
P8 = [indmax(Q[s, :]) for s = 1:size(Tr)[1]];
@test_approx_eq V1  V8
@assert P1 == P8

# timings

n = 100

print("Test 1: ")
@time for x = 1:n
  V1 = bellman1(V1, Tr, R, Q, 0.9)
end

print("Test 2: ")
@time for x = 1:n
  V2 = bellman2(V2, Tr, R, Q, 0.9)
end

print("Test 3: ")
@time for x = 1:n
  V3 = bellman3(V3, Tc, R, Q, 0.9)
end

print("Test 4: ")
@time for x = 1:n
  V4 = bellman4(V4, Tc, R, Q, 0.9)
end

print("Test 5: ")
@time for x = 1:n
  V5 = bellman5(V5, Tc, R, Q, 0.9)
end

print("Test 6: ")
@time for x = 1:n
  V6 = bellman6(V6, Tr, R, Q, 0.9)
end

print("Test 7: ")
@time for x = 1:n
  bellman7(V7new, V7old, Tc, R, 0.9, P7)
end

print("Test 7b: ")
@time for x = 1:n
  bellman7b(V7bnew, V7bold, Tc, R, 0.9, P7b)
end

print("Test 8: ")
@time for x = 1:n
  V8 = bellman6(V8, Tr, R, Q, 0.9)
end
