srand(0)
# Column-stochastic x
x_cs = rand(10, 10, 3)
x_cs = x_cs./sum(x_cs, 1)
# Row stochastic x
x_rs = similar(x_cs);
for k = 1:3
  x_rs[:, :, k] = x_cs[:, :, k]';
end

r = rand(10)
q = Array(Float64, 10, 3)

v = rand(10)
my_v = copy(v)

function normal_max(q, v, x, r)
  for k = 1:3
    q[:, k] = r + x[:, :, k] * v
  end
  [maximum(q[r, :]) for r = 1:10]
end

v = normal_max(q, v, x_rs, r)

function running_max(newv, oldv, x, r, q)
  newv[:] = copy(oldv)
  for k = 1:3
    for j = 1:10
      myq = r[j] + dot(x[:, j, k], oldv)
      #println( abs(myq - q[j, k]))
      if newv[j] < myq
        newv[j] = myq
      end
    end
  end
end

new_v = similar(my_v)
running_max(new_v, my_v, x_cs, r, q)

# myv and v should be equal
abs(v .- new_v) .< eps(max(maximum(abs(v)), maximum(abs(myv))))

# Indmax

x = rand(10, 3)

v1 = [maximum(x[r, :]) for r in 1:10]
p1 = [indmax(x[r, :]) for r in 1:10]

p2 = ones(Int, 10)
v2 = zeros(10)
for j = 1:3
  for i = 1:10
    if v2[i] < x[i, j]
      v2[i] = x[i, j]
      p2[i] = j
    end
  end
end
