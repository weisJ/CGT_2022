"""
An abstract wrapper for automatons which simply modify behaviour of some contained automaton.
By default it simply delegates all methods on 'AbstractAutomaton' to the wrapped automaton.
"""
abstract type AutomatonWrapper{S,X} <: AbstractAutomaton{S,X} end

"""
    wrappee(::AutomatonWrapper{S,X})
Access the wrapped automaton for purpose of delegation.
"""
function wrappee(::AutomatonWrapper{S,X}) where {S,X} end

alphabet(A::AutomatonWrapper{S,X}) where {S,X} = alphabet(wrappee(A))
has_edge(A::AutomatonWrapper{S,X}, state::S, label::Label{X}) where {S,X} = has_edge(wrappee(A), state, label)
edge_list(A::AutomatonWrapper{S,X}, state::S, label::Label{X}) where {S,X} = edge_list(wrappee(A), state, label)
states(A::AutomatonWrapper{S,X}) where {S,X} = states(wrappee(A))
trace(A::AutomatonWrapper{S,X}, label::Label{X}, state::S) where {S,X} = trace(wrappee(A), label, state)
initial_states(A::AutomatonWrapper{S,X}) where {S,X} = initial_states(wrappee(A))
terminal_states(A::AutomatonWrapper{S,X}) where {S,X} = terminal_states(wrappee(A))
is_terminal(A::AutomatonWrapper{S,X}, state::S) where {S,X} = is_terminal(wrappee(A), state)
state_iterator(A::AutomatonWrapper{S,X}; complete_loops::Bool=false) where {S,X} = state_iterator(wrappee(A); complete_loops)

epoch(A::AutomatonWrapper{S,X}) where {S,X} = epoch(wrappee(A))
advance_epoch!(A::AutomatonWrapper{S,X}) where {S,X} = advance_epoch!(wrappee(A))
epoch_flags(A::AutomatonWrapper{S,X}, s::S) where {S,X} = epoch_flags(wrappee(A), s)
