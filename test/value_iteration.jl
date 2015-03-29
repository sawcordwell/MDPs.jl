# ----------
# Small test
# ----------

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
