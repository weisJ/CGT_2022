
struct SubAutomaton{S,X} <: AutomatonWrapper{S,X}
    inner::AbstractAutomaton{S,X}
    states::Set{S}

    function SubAutomaton(A::AbstractAutomaton{S,X}, states::Set{S}, check::Bool=true) where {S,X}
        if check
            parent_states = states(A)
            for s ∈ states
                @assert s ∈ parent_states
            end
        end
        return new{S,X}(A, states)
    end
end

wrappee(A::SubAutomaton{S,X}) where {S,X} = A.inner

function has_edge(A::SubAutomaton{S,X}, state::S, label::Label{X}) where {S,X}
    has_edge(wrappee(A), state, label) || return false
    return trace(wrappee(A), label, state) ∈ A.states
end

edges(A::SubAutomaton{S,X}, state::S) where {S,X} =
    Iterators.filter(edges(wrappee(A), state)) do t
        _, s = t
        s ∈ A.states
    end

states(A::SubAutomaton{S,X}) where {S,X} = A.states

function trace(A::SubAutomaton{S,X}, label::Label{X}, state::S) where {S,X}
    σ = trace(wrappee(A), label, state)
    return σ ∈ A.states ? σ : nothing
end

initial_states(A::SubAutomaton{S,X}) where {S,X} =
    Iterators.filter(s::S -> s ∈ A.states, initial_states(wrappee(A)))

terminal_states(A::SubAutomaton{S,X}) where {S,X} =
    Iterators.filter(s::S -> s ∈ A.states, terminal_states(wrappee(A)))
