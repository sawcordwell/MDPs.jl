# ----------------
# Bellman operator
# ----------------

fixture_small() = MDPs.Examples.small()
fixture_small_initial_value() = [0.5, 0.5]
fixture_small_expected_value() = [10.45, 2.45]

let
    P, R = fixture_small()
    mdp = QMDP(P, R)
    bellman!(mdp, fixture_small_initial_value(), fixture_discount())
    @test_approx_eq value(mdp) fixture_small_expected_value()
end

let
    P, R = fixture_small()
    mdp = MDP(P, R, fixture_small_initial_value())
    bellman!(mdp, fixture_discount())
    @test_approx_eq value(mdp) fixture_small_expected_value()
end

# Fixture test
# ------------
let
    mdp = QMDP(fixture_transition(), fixture_reward())
    bellman!(mdp, fixture_initial_value(), fixture_discount())
    @test_approx_eq value(mdp) fixture_expected_value()
    @test policy(mdp) == fixture_expected_policy()
end

let
    mdp = MDP(fixture_transition(), fixture_reward(), fixture_initial_value())
    bellman!(mdp, fixture_discount())
    @test_approx_eq value(mdp) fixture_expected_value()
    @test policy(mdp) == fixture_expected_policy()
end

# Vector reward
# -------------
let
    mdp = QMDP(fixture_transition(), fixture_reward(:vector))
    bellman!(mdp, fixture_initial_value(), fixture_discount())
    @test_approx_eq value(mdp) fixture_expected_value(:vector)
    @test policy(mdp) == fixture_expected_policy(:vector)
end

let
    mdp = MDP(fixture_transition(), fixture_reward(:vector), fixture_initial_value())
    bellman!(mdp, fixture_discount())
    @test_approx_eq value(mdp) fixture_expected_value(:vector)
    @test policy(mdp) == fixture_expected_policy(:vector)
end

# ---------------
# Value Iteration
# ---------------

P, R = MDPs.Examples.small()

# Discounted
# ----------

policy_expected = [2, 1]
value_expected = [40.048625392716815, 33.65371175967546]

mdp = MDP(P, R)
value_iteration!(mdp, 0.9)
@test policy(mdp) == policy_expected
@test_approx_eq value(mdp) value_expected

mdp = QMDP(P, R)
value_iteration!(mdp, 0.9)
@test policy(mdp) == policy_expected
@test_approx_eq value(mdp) value_expected

# Undiscounted
# ------------

policy_expected = [2, 1]
value_expected = [117.84153597421569, 111.72677122062753]

mdp = MDP(P, R)
value_iteration!(mdp, 1)
@test policy(mdp) == policy_expected
@test_approx_eq value(mdp) value_expected

mdp = QMDP(P, R)
value_iteration!(mdp, 1)
@test policy(mdp) == policy_expected
@test_approx_eq value(mdp) value_expected

# The MDP-type version of the Bellman operator
# --------------------------------------------


