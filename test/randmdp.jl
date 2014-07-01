
mask = [false false false; true false true; false true false]
@test_throws ErrorException randmdp(size(mask, 1), 2, mask)

mask[1, 1] = true
@test_throws DimensionMismatch randmdp(size(mask, 1) + 1, 2, mask)

# Testing of the `randmdp` and `ismdp` functions with each other
for a = 2:10
    for s = 10:100
        P, R = randmdp(s, a)
        @test ismdp(P, R)
    end
end

P, R = randmdp(3, 2, mask)
@test ismdp(P, R)

mask = [x==y for x in 1:3, y in 1:3, z in 1:2]
P, R = randmdp(3, 2, mask)
@test ismdp(P, R)

