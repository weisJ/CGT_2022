"""
    is_deterministic(A::AbstractAutomaton{S,X})
Checks whether the automaton 'A' is deterministic.
"""
function is_deterministic(A::AbstractAutomaton{S,X}) where {S,X}
    length(initial_states(A)) > 1 && return false
    for σ ∈ states(A)
        for (l, _) ∈ edges(A, σ)
            l == ϵ && return false
        end
    end
    return true
end

"""
A state representing a subset of states from a different fixed automaton.
"""
mutable struct MultiState{X}
    transitions::Dict{X,MultiState{X}}
    states::BitSet
    flags::EpochFlags

    MultiState{X}() where {X} = new{X}(Dict{X,MultiState{X}}(), BitSet(), EpochFlags())
end

Base.:(==)(s1::MultiState{X}, s2::MultiState{X}) where {X} = (s1.states == s2.states)
Base.hash(s::MultiState{X}) where {X} = hash(s.states)
Base.show(io::IO, state::MultiState{X}) where {X} = print(io, "MultiState($(state.states))")

function contained_states(inner_states::Vector{S}, state::MultiState{X}) where {S,X}
    return (inner_states[i] for i ∈ state.states)
end

epoch_flags(::AbstractAutomaton{MultiState{X},X}, state::MultiState{X}) where {X} = state.flags

"""
An automaton which represents the subset construction on a given automaton 'A'.

The implemented algorithm follows section 3 and 4 in https://aclanthology.org/W98-1306.pdf
"""
mutable struct SubsetConstructionAutomaton{S,X} <: EpochStateAutomaton{MultiState{X},X}
    inner::AbstractAutomaton{S,X}
    states::Vector{MultiState{X}}
    initial_state::MultiState{X}
    terminal_states::Vector{MultiState{X}}

    function SubsetConstructionAutomaton(A::AbstractAutomaton{S,X}) where {S,X}
        inner_states::Vector{S} = vec(collect(states(A)))
        start = epsilon_closure(A, inner_states, initial_states(A))
        B = new{S,X}(A, Vector{MultiState{X}}(), start, Vector{MultiState{X}}())
        _subset_construction(A, B, inner_states)
        return B
    end
end

function _subset_construction(
    A::AbstractAutomaton{S,X},
    B::SubsetConstructionAutomaton{S,X},
    inner_states::Vector{S}
) where {S,X}
    states = OrderedDict{MultiState{X},MultiState{X}}()

    add = s::MultiState -> add_state!(A, B, inner_states, states, s)

    add(B.initial_state)

    for (_, T) ∈ states
        push!(B.states, T)

        for (l, σ) ∈ instructions(A, inner_states, T)
            U = epsilon_closure(A, inner_states, σ)
            # Make sure we use the appropriate object. Otherwise we link to incorrect
            # (speak dangling) states.
            if haskey(states, U)
                U = states[U]
            end
            T.transitions[l] = U
            add(U)
        end
    end
end

function add_state!(
    A::AbstractAutomaton{S,X},
    B::SubsetConstructionAutomaton{S,X},
    inner_states::Vector{S},
    states::OrderedDict{MultiState{X},MultiState{X}},
    state::MultiState
) where {S,X}
    haskey(states, state) && return
    states[state] = state
    for s ∈ contained_states(inner_states, state)
        if is_terminal(A, s)
            push!(B.terminal_states, state)
            break
        end
    end
end

function instructions(A::AbstractAutomaton{S,X}, inner_states::Vector{S}, state::MultiState{X}) where {S,X}
    inst = DefaultDict{X,MultiState}(() -> MultiState{X}())
    for s ∈ contained_states(inner_states, state)
        for (l, σ) ∈ edges(A, s)
            l == ϵ && continue
            push!(inst[l].states, findfirst(==(σ), inner_states))
        end
    end
    return inst
end

function epsilon_closure(
    A::AbstractAutomaton{S,X},
    inner_states::Vector{S},
    state::S;
    it::StateIterator{S}=state_iterator(A),
    accumulator=MultiState{X}()
) where {S,X}
    traverse(A, state, it;
        enter=s -> begin
            push!(accumulator.states, findfirst(==(s), inner_states))
            return Continue
        end,
        edge_filter=(l, _) -> l == ϵ
    )
    return accumulator
end

function epsilon_closure(A::AbstractAutomaton{S,X}, inner_states::Vector{S}, states) where {S,X}
    closure = MultiState{X}()
    it = state_iterator(A)
    for s ∈ states
        epsilon_closure(A, inner_states, s; it, accumulator=closure)
    end
    return closure
end

function epsilon_closure(A::AbstractAutomaton{S,X}, inner_states::Vector{S}, state::MultiState{X}) where {S,X}
    return epsilon_closure(A, inner_states, contained_states(inner_states, state))
end

alphabet(A::SubsetConstructionAutomaton{S,X}) where {S,X} = alphabet(A.inner)

has_edge(::SubsetConstructionAutomaton{S,X}, state::MultiState{X}, label::Label{X}) where {S,X} =
    label != ϵ && haskey(state.transitions, label)

function edge_list(A::SubsetConstructionAutomaton{S,X}, state::MultiState{X}, label::Label{X}) where {S,X}
    has_edge(A, state, label) || return MultiState{X}[]
    return (state.transitions[label],)
end

states(A::SubsetConstructionAutomaton{S,X}) where {S,X} = A.states
function trace(A::SubsetConstructionAutomaton{S,X}, label::Label{X}, state::MultiState{X}) where {S,X}
    has_edge(A, state, label) || return nothing
    return state.transitions[label]
end

initial_states(A::SubsetConstructionAutomaton{S,X}) where {S,X} = (A.initial_state,)
terminal_states(A::SubsetConstructionAutomaton{S,X}) where {S,X} = A.terminal_states
is_terminal(A::SubsetConstructionAutomaton{S,X}, state::MultiState{X}) where {S,X} = state ∈ A.terminal_states

state_iterator(A::SubsetConstructionAutomaton{S,X}; complete_loops::Bool=false) where {S,X} = EpochStateIterator(A, complete_loops)
epoch(A::SubsetConstructionAutomaton{State{X},X}) where {X} = epoch(A.inner)
advance_epoch!(A::SubsetConstructionAutomaton{State{X},X}) where {X} = advance_epoch!(A.inner)