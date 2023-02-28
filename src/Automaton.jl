mutable struct Automaton{X} <: EpochStateAutomaton{State{X},X}
    alphabet::Alphabet{X}
    states::Vector{State{X}}
    initial_states::Vector{State{X}}
    terminal_states::Set{State{X}}
    epoch::Int

    function Automaton(alphabet::Alphabet{X}) where {X}
        A = new{X}(alphabet)
        A.initial_states = [create_state(A)]
        A.states = copy(A.initial_states)
        A.terminal_states = Set{State{X}}()
        A.epoch = 0
        return A
    end
end

function _safe_state_count(A::Automaton)
    !isdefined(A, :states) && return 0
    return length(A.states)
end

alphabet(A::Automaton{X}) where {X} = A.alphabet

function has_edge(A::Automaton{X}, state::State{X}, label::Label{X}) where {X}
    index = indexin(alphabet(A), label)
    return haskey(state.transitions, index) && !isempty(state.transitions[index])
end

function edge_list(A::Automaton{X}, state::State{X}, l::Label{X}) where {X}
    has_edge(A, state, l) || return State{X}[]
    return state.transitions[indexin(alphabet(A), l)]
end

function trace(A::Automaton{X}, label::Label{X}, state::State{X}) where {X}
    has_edge(A, state, label) || return nothing
    return first(state.transitions[indexin(alphabet(A), label)])
end

initial_states(A::Automaton{X}) where {X} = A.initial_states
terminal_states(A::Automaton{X}) where {X} = A.terminal_states
is_terminal(A::Automaton{X}, state::State{X}) where {X} = state ∈ A.terminal_states
states(A::Automaton{X}) where {X} = A.states

create_state(A::Automaton{X}) where {X} = State(A)

state_iterator(A::Automaton{X}; complete_loops::Bool=false) where {X} = EpochStateIterator(A, complete_loops)
epoch(A::Automaton{X}) where {X} = A.epoch
advance_epoch!(A::Automaton{X}) where {X} = A.epoch += 1

"""
    add_state!(A::AbstractAutomaton{S,X}, state=create_state(A))
Adds a new state to the automaton. The state will not be connected to any other state by
default. If no state is passed a new state will be created.
The added state will be returned.
"""
function add_state!(A::Automaton{X}, state::State{X}=create_state(A)) where {X}
    push!(A.states, state)
    return state
end

"""
    add_edge!(::AbstractAutomaton{S,X}, source::S, label::X, target::S)
Adds a new edge to the automaton given by `(source, label, target)`.
"""
function add_edge!(A::Automaton{X}, source::State{X}, label::Label{X}, target::State{X}) where {X}
    @assert !has_edge(A, source, label) || !(target ∈ edge_list(A, source, label))
    push!(source.transitions[indexin(alphabet(A), label)], target)
end

"""
    mark_terminal!(::AbstractAutomaton{S,X}, state::S, terminal::Bool=true)
Mark the given state as being terminal i.e. accepting. By changing the `terminal``
parameter to `false` one is also able to unmark the state.
"""
function mark_terminal!(A::Automaton{X}, state::State{X}, terminal::Bool=true) where {X}
    if terminal
        push!(A.terminal_states, state)
    else
        delete!(A.terminal_states, state)
    end
end

"""
    mark_initial!(::AbstractAutomaton{S,X}, state::S, initial::Bool=true)
Mark the given state as being initial. By changing the `initial`
parameter to `false` one is also able to unmark the state.
"""
function mark_initial!(A::Automaton{X}, state::State{X}, initial::Bool=true) where {X}
    if initial
        push!(A.initial_states, state)
    else
        delete!(A.initial_states, state)
    end
end