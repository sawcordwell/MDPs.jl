
# The non-in-place version of the Bellman operator
# ------------------------------------------------

# With returning the policy
let
    value_got, policy_got = bellman(
        fixture_initial_value(),
        fixture_transition(),
        fixture_reward(),
        fixture_discount(),
        policy=true,
    )
    @test_approx_eq value_got fixture_expected_value()
    @test fixture_expected_policy() == policy_got
end

# Without returning the policy
let
    value_got = bellman(
        fixture_initial_value(),
        fixture_transition(),
        fixture_reward(),
        fixture_discount(),
    )
    @test_approx_eq value_got fixture_expected_value()
end

# The in-place version of the Bellman operator
# --------------------------------------------

# With returning the policy
let
    value_got = fixture_initial_value()
    policy_got = bellman!(
        value_got,
        fixture_transition(),
        fixture_reward(),
        fixture_discount(),
        policy=true,
    )
    @test_approx_eq value_got fixture_expected_value()
    @test fixture_expected_policy() == policy_got
end

# Without returning the policy
let
    value_got = fixture_initial_value()
    bellman!(
        value_got,
        fixture_transition(),
        fixture_reward(),
        fixture_discount(),
    )
    @test_approx_eq value_got fixture_expected_value()
end

# Vector rewards
# --------------

let
    value_got = bellman(
        fixture_initial_value(),
        fixture_transition(),
        fixture_reward(:vector),
        fixture_discount(),
    )
    @test_approx_eq value_got fixture_expected_value(:vector)
end

let
    value_got, policy_got = bellman(
        fixture_initial_value(),
        fixture_transition(),
        fixture_reward(:vector),
        fixture_discount(),
        policy=true,
    )
    @test_approx_eq value_got fixture_expected_value(:vector)
    @test fixture_expected_policy(:vector) == policy_got
end

# # Exactly representable floats
# # ----------------------------

# P = cat(3,
#         [0.5   0.25  0.25 0.0  ;
#          0.125 0.125 0.25 0.5  ;
#          0.0   0.5   0.0  0.5  ;
#          1.0   0.0   0.0  0.0  ]',
#         [0.0   0.0   1.0  0.0  ;
#          0.25  0.125 0.5  0.125;
#          0.0   1.0   0.0  0.0  ;
#          0.5   0.0   0.0  0.5  ]'
# )

# R = [1, 2, 3, 4]

# V = [0.25, 0.25, 0.25, 0.25]

# V_expected = [1.1875, 2.1875, 3.1875, 4.1875]

# for tp in (Float32, Float64)
#   Pt = convert(Array{tp}, P)
#   @assert all(sum(Pt, 1) .== one(tp))
#   @test is_square_stochastic(Pt)
#   for tr in (Int16, Int32, Int64, UInt8, UInt32, UInt64)
#     Rt = convert(Array{tr}, R)
#     mdp = MDP(Pt, Rt, tp)
#     bellman!(mdp, convert(Array{tp}, V), 0.75)
#     @test all(value(mdp) == convert(Array{tp}, V_expected))
#   end
# end
