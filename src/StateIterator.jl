"""
An abastract iterator for automatons, which traverses the states in a depth first fashion.
States can be marked for the purpose of "traverse and mark" algorithms. These marks are only valid
while the given iterator is the only active iterator.
"""
abstract type StateIterator{S} end

"""
    set_mark!(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, flag::Bool)
Set the marker of the state for the current iterator.
"""
function set_mark!(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, flag::Bool) where {S,X} end

"""
    get_mark(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, flag::Bool)
Get the marker of the state for the current iterator. This returns a `Bool`
or `nothing` if no marker has been set.
"""
function get_mark(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S) where {S,X} end

@enum IterationDecision Continue Break

"""
    traverse(A::AbstractAutomaton{S,X}, α::S, it::StateIterator{S}=state_iterator(A);
        enter::Function,
        exit::Function[=s->Continue],
        edge_filter::Function[=(l,σ) -> true])
Traverse the automaton states starting at `α`. The function `enter`
is used as a callback and receives the currently looked at state.
It returns either `Continue` or `Break` to continue down the graph or
stop iteration at the current state.
The `edge_filter` parameter can be used to filter the edges, which are traversed.

Traversal should be done in a depth first fashion, where states are visited only once, except in the following situation:
A state may be visited more than once if it aids in completing a loop such that the last edge of the loop is visited.
"""
function traverse(A::AbstractAutomaton{S,X}, α::S, it::StateIterator{S}=state_iterator(A);
    enter::F1, exit::F2=s::S -> Continue, edge_filter::F3=(_, _) -> true) where {S,X,F1,F2,F3} end
