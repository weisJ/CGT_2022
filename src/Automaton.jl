mutable struct State{X} <: AbstractState
    transitions::Vector{State{X}}

    State(A::AbstractAutomaton{State,X}) where {X} =
        new{X}(Vector{State{X}}(undef, length(alphabet(A))))
end

struct Automaton{X} <: AbstractAutomaton{State{X},X}
    alphabet::Vector{X}
    states::Vector{State{X}}
    initial::Vector{State{X}}
    terminal_states::Set{State{X}}

    function Automaton(alphabet::AbstractVector{X}) where {X}
        A = new{X}(alphabet)
        A.initial = [create_state(A)]
        A.terminal_states = Set{State{X}}()
        return A
    end
end

alphabet(A::Automaton{X}) where {X} = A.alphabet

has_edge(::Automaton{X}, label::X, state::State) where {X} = !isnothing(state.transitions[label])
trace(::Automaton{X}, label::X, state::State) where {X} = state.transitions[label]

initial_states(A::Automaton{X}) where {X} = A.initial
is_terminal(A::Automaton{X}, state::State{X}) where {X} = state ∈ A.terminal_states
states(A::Automaton{X}) where {X} = A.states

create_state(A::Automaton{X}) where {X} = State(A)
function add_state!(A::Automaton{X}, state::State{X}) where {X}
    push!(A.states, state)
end
function add_edge!(A::Automaton{X}, source::State{X}, label::X, target::State{X}) where {X}
    @assert !has_edge(A, source, label)
    source.transitions[label] = target
end