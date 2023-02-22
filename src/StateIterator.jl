# TODO: Document contract
abstract type StateIterator{S} end

"""
    set_mark!(it::StateIterator{S}, state::S, flag::Bool)
Set the marker of the state for the current iterator.
"""
function set_mark!(it::StateIterator{S}, state::S, flag::Bool) where {S} end

"""
    get_mark(it::StateIterator{S}, state::S, flag::Bool)
Get the marker of the state for the current iterator. This returns a `Bool`
or `nothing` if no marker has been set.
"""
function get_mark(it::StateIterator{S}, state::S) where {S} end

@enum IterationDecision Continue Break BreakAndExit

"""
    traverse(it::StateIterator{S}, α::S, enter::Function, exit::Function = doNothing)
Traverse the automaton states starting at `α`. The function `enter`
is used as a callback and receives the currently looked at state.
It returns either `Continue` or `Break` to continue down the graph or
stop iteration at the current state.
"""
function traverse(it::StateIterator{S}, α::S; enter::Function, exit::Function) where {S} end