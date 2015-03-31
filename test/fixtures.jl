
fixture_transition() = cat(3,
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


fixture_reward(shape::Symbol) = shape == :vector ?
    [0.82, -0.45, -0.42, -0.68,  0.37] :
    [0.82 -0.45 -0.42 -0.68  0.37;
     0.49 -0.95  0.46  0.66 -0.57;
    -0.73 -0.31 -0.07 -0.54 -0.29]'

fixture_reward() = fixture_reward(:array)


fixture_initial_value() = [0.04, 0.49, 0.24, 0.45, 0.82]


fixture_discount() = 0.9


fixture_expected_value(reward_shape::Symbol) = reward_shape == :vector ?
    [1.1818, 0.0283499999999999, -0.06405, -0.26015, 0.81325] :
    [1.08955, 0.02835, 0.7993, 1.07985, 0.81325]

fixture_expected_value() = fixture_expected_value(:array)


fixture_expected_policy(reward_shape::Symbol) = reward_shape == :vector ?
    [2, 1, 1, 2, 1] :
    [1, 1, 2, 2, 1]

fixture_expected_policy() = fixture_expected_policy(:array)
