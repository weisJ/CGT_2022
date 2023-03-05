
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

abstract type EpochStateAutomaton{S,X} <: AbstractAutomaton{S,X} end
function epoch(::EpochStateAutomaton{S,X}) where {S,X} end
function advance_epoch!(::EpochStateAutomaton{S,X}) where {S,X} end
function epoch_flags(::EpochStateAutomaton{S,X}, ::S)::EpochFlags where {S,X} end

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