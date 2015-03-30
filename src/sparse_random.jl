
sprand_reward{R}(::Type{R}, states, actions) =
    sprand(states, actions, 1/3, x -> rand_reward(R, x))


if VERSION < v"0.4-"
    # Adapted from
    # https://github.com/JuliaLang/julia/blob/v0.3.7/base/sparse/sparsematrix.jl
    function sprand_IJ(m::Integer, n::Integer, density::FloatingPoint)
        ((m < 0) || (n < 0)) && throw(ArgumentError("invalid Array dimensions"))
        0 <= density <= 1 || throw(ArgumentError("$density not in [0,1]"))
        N = n*m

        I, J = Array(Int, 0), Array(Int, 0) # indices of nonzero elements
        sizehint(I, int(N*density))
        sizehint(J, int(N*density))

        # density of nonzero columns:
        L = log1p(-density)
        coldensity = -expm1(m*L) # = 1 - (1-density)^m
        colsparsity = exp(m*L) # = 1 - coldensity
        L = 1/L

        rows = Array(Int, 0)
        for j in randsubseq(1:n, coldensity)
            # To get the right statistics, we *must* have a nonempty column j
            # even if p*m << 1.   To do this, we use an approach similar to
            # the one in randsubseq to compute the expected first nonzero row k,
            # except given that at least one is nonzero (via Bayes' rule);
            # carefully rearranged to avoid excessive roundoff errors.
            k = ceil(log(colsparsity + rand()*coldensity) * L)
            ik = k < 1 ? 1 : k > m ? m : int(k) # roundoff-error/underflow paranoia
            randsubseq!(rows, 1:m-ik, density)
            push!(rows, m-ik+1)
            append!(I, rows)
            nrows = length(rows)
            Jlen = length(J)
            resize!(J, Jlen+nrows)
            @inbounds for i = Jlen+1:length(J)
                J[i] = j
            end
        end
        I, J
    end
else
    import Base.SparseMatrix.sprand_IJ
end


function sprand_transition{T}(::Type{T}, states)
    I, J = VERSION < v"0.4-" ?
        sprand_IJ(states, states, 1/3) :
        sprand_IJ(Base.Random.GLOBAL_RNG, states, states, 1/3)
    V = rand(T, length(I))
    for j = 1:states
        idx = find(J .== j)
        if length(idx) == 0
            i = rand(1:states)
            push!(I, i)
            push!(J, j)
            push!(V, one(T))
        else
            V[idx] = V[idx] ./ sum(V[idx])
        end
    end
    sparse(I, J, V, states, states)
end


function sprandom{P<:FloatingPoint,R<:FloatingPoint}(
    ::Type{P},
    ::Type{R},
    states,
    actions,
)
    transition = SparseMatrixCSC{P,Int}[
        sprand_transition(P, states) for a = 1:actions
    ]
    reward = sprand_reward(R, states, actions)
    (transition, reward)
end


sprandom(states, actions) = sprandom(Float64, Float64, states, actions)
