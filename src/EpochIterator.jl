function epoch(::AbstractAutomaton{State{X},X}) where {X} end
function advance_epoch!(::AbstractAutomaton{State{X},X}) where {X} end

struct EpochStateIterator{X} <: StateIterator{State{X}}
    A::AbstractAutomaton{State{X},X}
    epoch::Int

    EpochStateIterator(A::AbstractAutomaton{State{X},X}) where {X} =
        new{X}(A, advance_epoch!(A))
end

const SeenFlag = 1
const MarkFlag = 2

function set_flag!(it::EpochStateIterator{X}, state::State{X}, flag::Int, value::Bool) where {X}
    state.epochs[flag] = it.epoch
    if value
        push!(state.flags, flag)
    else
        delete!(state.flags, flag)
    end
end

function get_flag(it::EpochStateIterator{X}, state::State{X}, flag::Int) where {X}
    state.epochs[flag] == it.epoch || return nothing
    return flag ∈ state.flags
end


function set_mark!(it::EpochStateIterator{X}, state::State{X}, flag::Bool) where {X}
    set_flag!(it, state, MarkFlag, flag)
end

function get_mark(it::EpochStateIterator{X}, state::State{X}) where {X}
    return get_flag(it, state, MarkFlag)
end

function do_traverse(
    it::EpochStateIterator{X}, α::State{X},
    enter::Function, exit::Function,
    parent_state_was_seen::Bool
)::IterationDecision where {X}
    state_seen = get_flag(it, α, SeenFlag) == true
    set_flag!(it, α, SeenFlag, true)

    enter(α) == Break && return Break

    if !parent_state_was_seen
        for (_, σ) ∈ edges(it.A, α)
            do_traverse(it, σ, enter, exit, state_seen) == Break && return Break
        end
    end

    exit(α)
    return Continue
end

function traverse(it::EpochStateIterator{X}, α::State{X}; enter::Function, exit::Function) where {X}
    do_traverse(it, α, enter, exit, false)
end