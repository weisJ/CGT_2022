struct IntersectionAutomaton{S1,S2,X} <: EpochStateAutomaton{Tuple{S1,S2},X}
    A::AbstractAutomaton{S1,X}
    B::AbstractAutomaton{S2,X}
    flags::DefaultDict{Tuple{S1,S2},EpochFlags}

    function IntersectionAutomaton(
        A::AbstractAutomaton{S1,X},
        B::AbstractAutomaton{S2,X}
    ) where {S1,S2,X}
        @assert alphabet(A) == alphabet(B)
        return new{S1,S2,X}(A, B, DefaultDict{Tuple{S1,S2},EpochFlags}(() -> EpochFlags()))
    end
end

alphabet(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} = alphabet(A.A)

has_edge(A::IntersectionAutomaton{S1,S2,X}, state::Tuple{S1,S2}, label::Label{X}) where {S1,S2,X} =
    has_edge(A.A, state[1], label) && has_edge(A.B, state[2], label)

function edge_list(A::IntersectionAutomaton{S1,S2,X}, state::Tuple{S1,S2}, label::Label{X}) where {S1,S2,X}
    list_A = edge_list(A.A, state[1], label)
    list_B = edge_list(A.B, state[2], label)
    return Iterators.zip(list_A, list_B)
end

function trace(A::IntersectionAutomaton{S1,S2,X}, label::Label{X}, state::Tuple{S1,S2}) where {S1,S2,X}
    τ_A = trace(A.A, label, state[1])
    τ_B = trace(A.B, label, state[2])
    isnothing(τ_A) && return nothing
    isnothing(τ_B) && return nothing
    return (τ_A, τ_B)
end

states(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.product(states(A.A), states(A.B))

initial_states(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.product(initial_states(A.A), initial_states(A.B))

terminal_states(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.product(terminal_states(A.A), terminal_states(A.B))

is_terminal(A::IntersectionAutomaton{S1,S2,X}, state::Tuple{S1,S2}) where {S1,S2,X} =
    is_terminal(A.A, state[1]) && is_terminal(A.B, state[2])

epoch(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} = epoch(A.A)
advance_epoch!(A::IntersectionAutomaton{S1,S2,X}) where {S1,S2,X} = advance_epoch!(A.A)

epoch_flags(A::IntersectionAutomaton{S1,S2,X}, s::Tuple{S1,S2}) where {S1,S2,X} =
    A.flags[s]

state_iterator(A::IntersectionAutomaton{S1,S2,X}; complete_loops::Bool=false) where {S1,S2,X} =
    EpochStateIterator(A, complete_loops)
