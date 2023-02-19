mutable struct State{X} <: AbstractState
    transitions::Vector{State{X}}

    State(A::T) where {X,T<:AbstractAutomaton{State{X},X}} =
        new{X}(Vector{State{X}}(undef, length(alphabet(A)) + 1))
end

mutable struct Automaton{X} <: AbstractAutomaton{State{X},X}
    alphabet::Alphabet{X}
    states::Vector{State{X}}
    initial::Vector{State{X}}
    terminal_states::Set{State{X}}

    function Automaton(alphabet::Alphabet{X}) where {X}
        A = new{X}(alphabet)
        A.initial = [create_state(A)]
        A.states = copy(A.initial)
        A.terminal_states = Set{State{X}}()
        return A
    end
end

alphabet(A::Automaton{X}) where {X} = A.alphabet

has_edge(A::Automaton{X}, state::State, label::Label{X}) where {X} =
    isassigned(state.transitions, indexof(alphabet(A), label))
function trace(A::Automaton{X}, label::Label{X}, state::State) where {X}
    has_edge(A, state, label) || return nothing
    state.transitions[indexof(alphabet(A), label)]
end

initial_states(A::Automaton{X}) where {X} = A.initial
is_terminal(A::Automaton{X}, state::State{X}) where {X} = state ∈ A.terminal_states
states(A::Automaton{X}) where {X} = A.states

create_state(A::Automaton{X}) where {X} = State(A)

"""
    add_state!(A::AbstractAutomaton{S,X}, state=create_state(A))
Adds a new state to the automaton. The state will not be connected to any other state by
default. If no state is passed a new state will be created.
The added state will be returned.
"""
function add_state!(A::Automaton{X}, state::State{X} = create_state(A)) where {X}
    push!(A.states, state)
    return state
end

"""
    add_edge!(::AbstractAutomaton{S,X}, source::S, label::X, target::S)
Adds a new edge to the automaton given by `(source, label, target)`.
"""
function add_edge!(A::Automaton{X}, source::State{X}, label::Label{X}, target::State{X}) where {X}
    @assert !has_edge(A, source, label)
    source.transitions[indexof(alphabet(A), label)] = target
end

"""
    mark_terminal!(::AbstractAutomaton{S,X}, state::S, terminal::Bool=true)
Mark the given state as being terminal i.e. accepting. By changing the `terminal``
parameter to `false` one is also able to unmark the state.
"""
function mark_terminal!(A::Automaton{X}, state::State{X}, terminal::Bool = true) where {X}
    if terminal
        push!(A.terminal_states, state)
    else
        delete!(A.terminal_states, state)
    end
end