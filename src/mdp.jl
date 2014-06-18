type MDP{P<:FloatingPoint,R<:Real} <: AbstractMDP{P,R}
    transition::Array{P,3}
    reward::Array{R,2}
    policy::Array{Uint8,1}
    value::Array{R,1}
    S::Int
    A::Uint8
    function MDP(transition::Array{P,3}, reward::Array{R,2})
        if !ismdp(transition, reward)
            error("Not a valid MDP.")
        end
        S, A = size(transition)[[1,3]]
        new(transition, reward, zeros(Uint8, S), zeros(R, S), S, A)
    end
end
