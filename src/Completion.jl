struct ErrorState end

const CompletionState = Union{S,ErrorState} where {S}

struct AutomatonCompletion{S,X} <: AutomatonWrapper{CompletionState{S},X}
    inner::AbstractAutomaton{S,X}
    error_state::ErrorState

    AutomatonCompletion(A::AbstractAutomaton{S,X}) where {S,X} = new{S,X}(A, ErrorState())
end

wrappee(A::AutomatonCompletion) = A.inner

function initial_states(A::AutomatonCompletion)
    states = initial_states(wrappee(A))
    isempty(states) && return [A.error_state]
    return states
end

function has_edge(A::AutomatonCompletion{S,X}, state::CompletionState{S}, label::Label{X}) where {S,X}
    label != ϵ && return true
    state == A.error_state && return false
    return has_edge(A, label, state)
end

function edge_list(A::AutomatonCompletion{S,X}, state::CompletionState{S}, l::Label{X}) where {S,X}
    error = [A.error_state]
    if state == A.error_state
        return ((l, error) for l ∈ letters_with_epsilon(alphabet(A)))
    end
    E = edge_list(wrappee(A), state, l)
    isnothing(E) && return error
    return E
end

function states(A::AutomatonCompletion{S,X}) where {S,X}
    return CatView(states(wrappee(A)), [A.error_state])
end

function trace(A::AutomatonCompletion{S,X}, label::X, state::CompletionState{S}) where {S,X}
    if state == A.error_state
        return label == ϵ ? nothing : A.error_state
    end
    has_edge(A.A, label, state) || return A.error_state
    return trace(A.A, label, state)
end

function is_terminal(A::AutomatonCompletion{S,X}, state::CompletionState{S}) where {S,X}
    state == A.error_state && return false
    return is_terminal(A.A, state)
end

function completion(A::AbstractAutomaton{S,X}) where {S,X}
    return AutomatonCompletion(A)
end

function is_complete(A::AbstractAutomaton{S,X}) where {S,X}
    for σ ∈ states(A)
        for l ∈ alphabet(A)
            l == ϵ && continue
            has_edge(A, σ, l) || return false
        end
    end
    return true
end