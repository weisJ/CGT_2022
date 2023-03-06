"""
Helper struct for implementing 'EpochStateAutomaton' on a type of automaton.
"""
mutable struct EpochFlags
    flags::BitSet
    epochs::MVector{2,Int}

    EpochFlags() = new(BitSet(), @MVector [-1, -1])
end

const SeenFlag = 1
const MarkFlag = 2

function set_flag!(epoch::EpochFlags, current_epoch::Int, flag::Int, value::Bool)
    epoch.epochs[flag] = current_epoch
    if value
        push!(epoch.flags, flag)
    else
        delete!(epoch.flags, flag)
    end
end

function get_flag(epoch::EpochFlags, current_epoch::Int, flag::Int)
    epoch.epochs[flag] == current_epoch || return nothing
    return flag ∈ epoch.flags
end

"""
Automatons compatible with 'EpochStateIterator' must implement functions:
    epoch(::EpochStateAutomaton{S,X})
    advance_epoch!(::EpochStateAutomaton{S,X})
    epoch_flags(::EpochStateAutomaton{S,X}, ::S)
"""
abstract type EpochStateAutomaton{S,X} <: AbstractAutomaton{S,X} end
"""
    epoch(A::EpochStateAutomaton{S,X})
Returns the current epoch of the automaton 'A'.
"""
function epoch(::EpochStateAutomaton{S,X}) where {S,X} end
"""
    advance_epoch!(A::EpochStateAutomaton{S,X})
Advance the current epoch of 'A' and return it.
"""
function advance_epoch!(::EpochStateAutomaton{S,X}) where {S,X} end#
"""
    epoch_flags(A::EpochStateAutomaton{S,X}, s::S)
Access the 'EpochFlags' of the state 's'.
"""
function epoch_flags(::EpochStateAutomaton{S,X}, ::S)::EpochFlags where {S,X} end

"""
An iterator implementation for automatons, which doesn't need to use additional allocations during traversal for
checking before visited states.
This is done by storing the seen/mark flags inside the states together with an 'epoch', which is simply a number which gets
incremented each time the automaton is traversed.
The value inside the flag is then only valid if the epoch of the flag equals the epoch at the time of transversal.
"""
struct EpochStateIterator{S,X} <: StateIterator{S}
    epoch::Int
    complete_loops::Bool

    EpochStateIterator(A::EpochStateAutomaton{S,X}, complete_loops::Bool) where {S,X} =
        new{S,X}(advance_epoch!(A), complete_loops)
end

set_flag!(it::EpochStateIterator{S,X}, A::AbstractAutomaton{S,X}, state::S, flag::Int, value::Bool) where {S,X} =
    set_flag!(epoch_flags(A, state), it.epoch, flag, value)

get_flag(it::EpochStateIterator{S,X}, A::AbstractAutomaton{S,X}, state::S, flag::Int) where {S,X} =
    get_flag(epoch_flags(A, state), it.epoch, flag)

set_mark!(it::EpochStateIterator{S,X}, A::AbstractAutomaton{S,X}, state::S, flag::Bool) where {S,X} =
    set_flag!(it, A, state, MarkFlag, flag)

get_mark(it::EpochStateIterator{S,X}, A::AbstractAutomaton{S,X}, state::S) where {S,X} =
    get_flag(it, A, state, MarkFlag)

function do_traverse(
    A::AbstractAutomaton{S,X},
    α::S,
    it::EpochStateIterator{S,X},
    enter::F1, exit::F2, edge_filter::F3,
    parent_state_was_seen::Bool
)::IterationDecision where {S,X,F1,F2,F3}
    state_seen = get_flag(it, A, α, SeenFlag) == true
    state_seen && !it.complete_loops && return Continue

    set_flag!(it, A, α, SeenFlag, true)

    return_state = Continue

    if enter(α) == Break
        return_state = Break
    elseif !parent_state_was_seen
        for (l, σ) ∈ edges(A, α)
            edge_filter(l, σ) || continue
            if do_traverse(A, σ, it, enter, exit, edge_filter, state_seen) == Break
                return_state = Break
                break
            end
        end
    end

    exit(α)
    return return_state
end

function traverse(
    A::AbstractAutomaton{S,X},
    α::S,
    it::EpochStateIterator{S,X};
    enter::F1,
    exit::F2=s::S -> Continue,
    edge_filter::F3=(_, _) -> true
) where {S,X,F1,F2,F3}
    do_traverse(A, α, it, enter, exit, edge_filter, false)
end