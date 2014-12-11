# ----------
# Small test
# ----------

P, R = smallmdp()
value_initial = [0.5, 0.5]
value_expected = [10.45, 2.45]
discount = 0.9

mdp = QMDP(P, R)
bellman!(mdp, value_initial, discount)
@test_approx_eq value(mdp) value_expected

mdp = MDP(P, R, value_initial)
bellman!(mdp, discount)
@test_approx_eq value(mdp) value_expected

# -----------
# Larger test
# -----------

# Fixtures
# --------

P = cat(3,
  [0.4  0.4  0.1  0.05 0.05;
   0.1  0.35 0.1  0.1  0.35;
   0.25 0.2  0.25 0.05 0.25;
   0.05 0.25 0.3  0.25 0.15;
   0.2  0.2  0.15 0.05 0.40]',
  [0.3  0.15 0.2  0.05 0.3 ;
   0.25 0.1  0.25 0.3  0.1 ;
   0.25 0.2  0.25 0.1  0.2 ;
   0.2  0.15 0    0.4  0.25;
   0.4  0    0.45 0.15 0   ]',
  [0.1  0.2  0.3  0.4  0   ;
   0.15 0.3  0.4  0.1  0.05;
   0.35 0.15 0.3  0.1  0.1 ;
   0.3  0.2  0.3  0.1  0.1 ;
   0.3  0.3  0.2  0.05 0.15]'
)

R = [ 0.82 -0.45 -0.42 -0.68  0.37;
      0.49 -0.95  0.46  0.66 -0.57;
     -0.73 -0.31 -0.07 -0.54 -0.29]'

value_initial = [0.04, 0.49, 0.24, 0.45, 0.82]

discount = 0.9

value_expected = [1.08955, 0.02835, 0.7993, 1.07985, 0.81325]
policy_expected = [1, 1, 2, 2, 1]

# The non-in-place version of the Bellman operator
# ------------------------------------------------

# With returning the policy
value_got, policy_got = bellman(value_initial, P, R, discount, policy=true)
@test_approx_eq value_got value_expected
@test policy_expected == policy_got

# Without returning the policy
value_got = bellman(value_initial, P, R, discount)
@test_approx_eq value_got value_expected

# The in-place version of the Bellman operator
# --------------------------------------------

# With returning the policy
value_got = copy(value_initial)
policy_got = bellman!(value_got, P, R, discount, policy=true)
@test_approx_eq value_got value_expected
@test policy_expected == policy_got

# Without returning the policy
value_got = copy(value_initial)
bellman!(value_got, P, R, discount)
@test_approx_eq value_got value_expected

# The MDP-type version of the Bellman operator
# --------------------------------------------

mdp = QMDP(P, R)
bellman!(mdp, value_initial, discount)
@test_approx_eq value(mdp) value_expected
@test policy(mdp) == policy_expected

mdp = MDP(P, R, value_initial)
bellman!(mdp, discount)
@test_approx_eq value(mdp) value_expected
@test policy(mdp) == policy_expected

# Vector rewards
# --------------
R = [0.82, -0.45, -0.42, -0.68,  0.37]

value_expected = [1.1818, 0.0283499999999999, -0.06405, -0.26015, 0.81325]
policy_expected = [2, 1, 1, 2, 1]

value_got = bellman(value_initial, P, R, discount)
@test_approx_eq value_got value_expected

value_got, policy_got = bellman(value_initial, P, R, discount, policy=true)
@test_approx_eq value_got value_expected
@test policy_expected == policy_got

mdp = QMDP(P, R)
bellman!(mdp, value_initial, discount)
@test_approx_eq value_got value_expected
@test policy(mdp) == policy_expected

mdp = MDP(P, R, value_initial)
bellman!(mdp, discount)
@test_approx_eq value(mdp) value_expected
@test policy(mdp) == policy_expected

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

# for tp in (Float16, Float32, Float64)
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
