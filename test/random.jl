
mask = [false false false; true false true; false true false]
@test_throws ErrorException MDPs.Examples.random(size(mask, 1), 2, mask)

mask[1, 1] = true
@test_throws ErrorException MDPs.Examples.random(size(mask, 1) + 1, 2, mask)

P, R = MDPs.Examples.random(3, 2, mask)
@test ismdp(P, R)

mask = [x==y for x in 1:3, y in 1:3, z in 1:2]
P, R = MDPs.Examples.random(3, 2, mask)
@test ismdp(P, R)
