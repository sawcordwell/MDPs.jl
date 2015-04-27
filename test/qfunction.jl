
facts("ArrayQFunction construction") do
    @fact typeof(ArrayQFunction(zeros(5, 3))) => ArrayQFunction{Float64}
    @fact ArrayQFunction(5, 3) == ArrayQFunction(zeros(5, 3)) => true
    @fact ArrayQFunction(Float32, 5, 3) == ArrayQFunction(zeros(Float32, 5, 3)) => true
    @fact_throws MethodError ArrayQFunction(zeros(5))
    @fact_throws MethodError ArrayQFunction(zeros(5, 3, 2))
end

facts("ArrayQFunction methods") do
    qf = ArrayQFunction(Float64[1 2 3; 3 2 1; 2 2 2; 1 1 3; 2 3 1])
    @fact value(qf) => [3.0, 3.0, 2.0, 3.0, 3.0]
    @fact policy(qf) => [3, 1, 1, 3, 2]
    @fact policy(UInt8, qf) => [0x03, 0x01, 0x01, 0x03, 0x02]
    @fact value(qf, 2) => 3.0
    @fact policy(qf, 2) => 1
    @fact getvalue(qf, 1, 2) => 2.0
    @fact num_states(qf) => 5
    @fact num_actions(qf) => 3
end

facts("ArrayQFunction setvalue!") do
    qf = ArrayQFunction(Float64[1 2 3; 3 2 1; 2 2 2; 1 1 3; 2 3 1])
    setvalue!(qf, 4.0, 1, 2)
    @fact getvalue(qf, 1, 2) => 4.0
    setvalue!(qf, 3, 2, 1)
    @fact getvalue(qf, 2, 1) => 3.0
end

facts("VectorQFunction construction") do
    @fact typeof(VectorQFunction(zeros(5), zeros(Int, 5))) => VectorQFunction{Float64,Int}
    @fact VectorQFunction(5) == VectorQFunction(zeros(5), zeros(Int, 5)) => true
    @fact VectorQFunction(Float32, UInt8, 5) == VectorQFunction(zeros(Float32, 5), zeros(UInt8, 5)) => true
    @fact_throws DimensionMismatch VectorQFunction(zeros(5), zeros(Int, 6))
end

facts("VectorQFunction methods") do
    qf = VectorQFunction([3.0, 3.0, 2.0, 3.0, 3.0], [3, 1, 1, 3, 2])
    @fact value(qf) => [3.0, 3.0, 2.0, 3.0, 3.0]
    @fact policy(qf) => [3, 1, 1, 3, 2]
    @fact value(qf, 2) => 3.0
    @fact policy(qf, 2) => 1
    @fact_throws MethodError value(qf, 1, 2)
    @fact num_states(qf) => 5
    @fact_throws MethodError num_actions(qf)
    qf_new = copy(qf)
    @fact qf_new == qf => true
    @fact qf_new === qf => false
end

facts("VectorQFunction setvalue! assigned") do
    qf = VectorQFunction([3.0, 3.0, 2.0, 3.0, 3.0], [3, 1, 1, 3, 2])
    setvalue!(qf, 4.0, 1, 2)
    @fact value(qf, 1) => 4.0
    @fact policy(qf, 1) => 2
end

facts("VectorQFunction setvalue! not assigned") do
    qf = VectorQFunction([3.0, 3.0, 2.0, 3.0, 3.0], [3, 1, 1, 3, 2])
    setvalue!(qf, 2.0, 1, 2)
    @fact value(qf, 1) => 3.0
    @fact policy(qf, 1) => 3
end

facts("helper constructor") do
    @fact typeof(QFunction(zeros(5, 3))) => ArrayQFunction{Float64}
    @fact typeof(QFunction(zeros(5), zeros(Int, 5))) => VectorQFunction{Float64,Int}
end

facts("copy value! to vector") do
    qf = ArrayQFunction(rand(5, 3))
    val = Array(Float64, 5)
    value!(val, qf)
    @fact val == value(qf) => true
    @fact val === value(qf) => false
    @fact_throws BoundsError value!(Array(Float64, 4), qf)
    qf = VectorQFunction(rand(5), rand(Int, 5))
    val = Array(Float64, 5)
    value!(val, qf)
    @fact val == value(qf) => true
    @fact val === value(qf) => false
    @fact_throws BoundsError value!(Array(Float64, 4), qf)
end

facts("copy policy! to vector") do
    qf = ArrayQFunction(rand(5, 3))
    pol = Array(Int, 5)
    policy!(pol, qf)
    @fact pol == policy(qf) => true
    @fact pol === policy(qf) => false
    @fact_throws BoundsError policy!(Array(Int, 4), qf)
    qf = VectorQFunction(rand(5), rand(Int, 5))
    pol = Array(Int, 5)
    policy!(pol, qf)
    @fact pol == policy(qf) => true
    @fact pol === policy(qf) => false
    @fact_throws BoundsError policy!(Array(Int, 4), qf)
end
