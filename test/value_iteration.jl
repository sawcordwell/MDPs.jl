P, R = smallmdp()
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
