abstract type AutomatonWrapper{S,X} <: AbstractAutomaton{S,X} end

function wrappee(::AutomatonWrapper{S,X}) where {S,X} end

alphabet(A::AutomatonWrapper{S,X}) where {S,X} = alphabet(wrappee(A))
has_edge(A::AutomatonWrapper{S,X}, label::X, state::S) where {S,X} = has_edge(wrappee(A), label, state)
edges(A::AutomatonWrapper{S,X}, state::S) where {S,X} = edges(wrappee(A), state)
trace(A::AutomatonWrapper{S,X}, label::X, state::S) where {S,X} = trace(wrappee(A), label, state)
initial_states(A::AutomatonWrapper{S,X}) where {S,X} = initial_states(wrappee(A))
is_terminal(A::AutomatonWrapper{S,X}, state::S) where {S,X} = is_terminal(wrappee(A), state)
create_state(A::AutomatonWrapper{S,X}) where {S,X} = create_state(wrappee(A))
add_state!(A::AutomatonWrapper{S,X}, state::S) where {S,X} = add_state!(wrappee(A), state)
add_edge!(A::AutomatonWrapper{S,X}, source::S, label::X, target::S) where {S,X} =
    add_edge!(wrappee(A), source, label, target)
mark_terminal!(A::AutomatonWrapper{S,X}, state::S, terminal::Bool) where {X,S} =
    mark_terminal!(A, state, terminal)