mutable struct State{X} <: AbstractState
    transitions::Vector{State{X}}

    State(A::T) where {X,T<:AbstractAutomaton{State{X},X}} =
        new{X}(Vector{State{X}}(undef, length(alphabet(A))))
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

has_edge(A::Automaton{X}, state::State, label::X) where {X} =
    isassigned(state.transitions, indexof(alphabet(A), label))
function trace(A::Automaton{X}, label::X, state::State) where {X}
    has_edge(A, state, label) || return nothing
    state.transitions[indexof(alphabet(A), label)]
end

initial_states(A::Automaton{X}) where {X} = A.initial
is_terminal(A::Automaton{X}, state::State{X}) where {X} = state ∈ A.terminal_states
states(A::Automaton{X}) where {X} = A.states

create_state(A::Automaton{X}) where {X} = State(A)

function add_state!(A::Automaton{X}, state::State{X}) where {X}
    push!(A.states, state)
    return state
end

function add_edge!(A::Automaton{X}, source::State{X}, label::X, target::State{X}) where {X}
    @assert !has_edge(A, source, label)
    source.transitions[indexof(alphabet(A), label)] = target
end

function mark_terminal!(A::Automaton{X}, state::State{X}, terminal::Bool) where {X}
    if terminal
        push!(A.terminal_states, state)
    else
        delete!(A.terminal_states, state)
    end
end