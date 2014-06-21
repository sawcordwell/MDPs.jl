type MDP{P<:FloatingPoint,R<:Real} <: AbstractMDP{P,R}
    transition::Array{P,3}
    reward::Array{R,2}
    value::Array{Float64,1}
    S::Int
    A::Uint8
    function MDP(transition::Array{P,3}, reward::Array{R,2})
        if !ismdp(transition, reward)
            error("Not a valid MDP.")
        end
        S, A = size(transition)[[1,3]]
        new(transition, reward, zeros(Float64, S), S, A)
    end
end

#typealias InitialValueMDP{P<:FloatingPoint,R<:Real}(transition::Array{P,3}, reward::Array{R,2}, value0::Array{R,1}) = 
#    MDP(transition, reward, zeros(Uint8...

# TODO: add option of specifying initial value vector
function value_iteration!(mdp::MDP, discount::Float64, epsilon::Float64)
    #
end

# The Bellman operator from Bellman R (1957) "A Markovian decision process"
#
# mdp The Markov decision process of type MDP
# δ The discount factor, 0 < discount ≤ 1
#
function bellman!(mdp::MDP, δ::Float64)
    for a in 1:mdp.A
        mdp.value[:,a] = mdp.reward[:,a] + δ .* mdp.transition * mdp.value[:,a]
    end
end

policy(mdp::MDP) = Uint8[ indmax(mdp.value[s,:]) for s = 1:mdp.S ]

value(mdp::MDP) = maximum(mdp.value, 2)

