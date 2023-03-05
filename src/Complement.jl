struct ComplementAutomaton{S,X} <: AutomatonWrapper{S,X}
    inner::AbstractAutomaton{S,X}
    ComplementAutomaton(A::AbstractAutomaton{S,X}) where {S,X} = new{S,X}(A)
end

wrappee(A::ComplementAutomaton{S,X}) where {S,X} = A.inner
is_terminal(A::ComplementAutomaton{S,X}, state::S) where {S,X} = !is_terminal(wrappee(A), state)
terminal_states(A::ComplementAutomaton{S,X}) where {S,X} = (s for s ∈ states(A) if is_terminal(A, s))


function complement(A::AbstractAutomaton{S,X}) where {S,X}
    return ComplementAutomaton(A)
end