# Testing of the `randmdp` and `ismdp` functions with each other
for a = 2:10
    for s = 10:100
        P, R = randmdp(s, a)
        @test ismdp(P, R)
    end
end
