function epoch(::AbstractAutomaton{State{X},X}) where {X} end
function advance_epoch!(::AbstractAutomaton{State{X},X}) where {X} end

struct EpochStateIterator{X} <: StateIterator{State{X}}
    epoch::Int

    EpochStateIterator(A::AbstractAutomaton{State{X},X}) where {X} =
        new{X}(advance_epoch!(A))
end

set_flag!(it::EpochStateIterator{X}, state::State{X}, flag::Int, value::Bool) where {X} =
    set_flag!(state.epoch, it.epoch, flag, value)

get_flag(it::EpochStateIterator{X}, state::State{X}, flag::Int) where {X} =
    get_flag(state.epoch, it.epoch, flag)

set_mark!(it::EpochStateIterator{X}, state::State{X}, flag::Bool) where {X} =
    set_flag!(it, state, MarkFlag, flag)

get_mark(it::EpochStateIterator{X}, state::State{X}) where {X} =
    return get_flag(it, state, MarkFlag)

function do_traverse(
    A::AbstractAutomaton{S,X},
    α::State{X},
    it::EpochStateIterator{X},
    enter::Function, exit::Function,
    parent_state_was_seen::Bool
)::IterationDecision where {S,X}
    state_seen = get_flag(it, α, SeenFlag) == true
    set_flag!(it, α, SeenFlag, true)

    enter(α) == Break && return Break

    if !parent_state_was_seen
        for (_, σ) ∈ edges(A, α)
            do_traverse(A, σ, it, enter, exit, state_seen) == Break && return Break
        end
    end

    exit(α)
    return Continue
end

function traverse(
    A::AbstractAutomaton{S,X},
    α::State{X},
    it::EpochStateIterator{X};
    enter::Function,
    exit::Function
) where {S,X}
    do_traverse(A, α, it, enter, exit, false)
end