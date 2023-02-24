
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

abstract type EpochState end
function epoch_flags(::EpochState)::EpochFlags end

abstract type EpochStateAutomaton{S<:EpochState,X} <: AbstractAutomaton{S,X} end
function epoch(::EpochStateAutomaton{S,X}) where {S,X} end
function advance_epoch!(::EpochStateAutomaton{S,X}) where {S,X} end

struct EpochStateIterator{S,X} <: StateIterator{S}
    epoch::Int
    complete_loops::Bool

    EpochStateIterator(A::EpochStateAutomaton{S,X}, complete_loops::Bool) where {S,X} =
        new{S,X}(advance_epoch!(A), complete_loops)
end

set_flag!(it::EpochStateIterator{S,X}, state::EpochState, flag::Int, value::Bool) where {S,X} =
    set_flag!(epoch_flags(state), it.epoch, flag, value)

get_flag(it::EpochStateIterator{S,X}, state::EpochState, flag::Int) where {S,X} =
    get_flag(epoch_flags(state), it.epoch, flag)

set_mark!(it::EpochStateIterator{S,X}, ::EpochStateAutomaton{S,X}, state::EpochState, flag::Bool) where {S,X} =
    set_flag!(it, state, MarkFlag, flag)

get_mark(it::EpochStateIterator{S,X}, ::EpochStateAutomaton{S,X}, state::EpochState) where {S,X} =
    get_flag(it, state, MarkFlag)

function do_traverse(
    A::AbstractAutomaton{S,X},
    α::S,
    it::EpochStateIterator{S,X},
    enter::Function, exit::Function, edge_filter::Function,
    parent_state_was_seen::Bool
)::IterationDecision where {S,X}
    state_seen = get_flag(it, α, SeenFlag) == true
    state_seen && !it.complete_loops && return Continue

    set_flag!(it, α, SeenFlag, true)

    enter(α) == Break && return Break

    if !parent_state_was_seen
        for (l, σ) ∈ edges(A, α)
            edge_filter(l, σ) || continue
            do_traverse(A, σ, it, enter, exit, edge_filter, state_seen) == Break && return Break
        end
    end

    exit(α)
    return Continue
end

function traverse(
    A::AbstractAutomaton{S,X},
    α::S,
    it::EpochStateIterator{S,X};
    enter::Function,
    exit::Function=s::S -> Continue,
    edge_filter::Function=(_, _) -> true
) where {S,X}
    do_traverse(A, α, it, enter, exit, edge_filter, false)
end