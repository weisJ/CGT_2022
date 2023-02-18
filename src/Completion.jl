struct AutomatonCompletion{S,X} <: AutomatonWrapper{S,X}
    inner::AbstractAutomaton{S,X}
    error_state::S

    AutomatonCompletion(A::AbstractAutomaton{S,X}) where {S,X} = new{S,X}(A, create_state(A))
end

wrappee(A::AutomatonCompletion) = A.inner

function initial_states(A::AutomatonCompletion)
    states = initial_states(wrappee(A))
    isempty(states) && return [A.error_state]
    return states
end

has_edge(::AutomatonCompletion{S,X}, label::X, state::S) where {S,X} = true
function edges(A::AutomatonWrapper{S,X}, state::S) where {S,X}
    max_degree = length(alphabet(A))
    E = edges(wrappee(A), state)
    if length(E) == max_degree
        return E
    else
        return CatView(E, [A.error_state])
    end
end

function states(A::AutomatonWrapper{S,X}) where {S,X}
    return CatView(states(wrappee(A)), [A.error_state])
end

function trace(A::AutomatonCompletion{S,X}, label::X, state::S) where {S,X}
    has_edge(A.A, label, state) || return A.error_state
    return trace(A.A, label, state)
end

function is_terminal(A::AutomatonCompletion{S,X}, state::S) where {S,X}
    state == A.error_state && return false
    return is_terminal(A.A, state)
end

function completion(A::AbstractAutomaton{S,X}) where {S,X}
    return AutomatonCompletion(A)
end