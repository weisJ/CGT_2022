mutable struct State{X}
    transitions::DefaultDict{Int,Vector{State{X}}}
    id::Int
    flags::EpochFlags

    State(A::T) where {X,T<:AbstractAutomaton{State{X},X}} =
        new{X}(
            DefaultDict{Int,Vector{State{X}}}(() -> Vector{State{X}}()),
            _safe_state_count(A) + 1,
            EpochFlags())
end

epoch_flags(state::State{X}) where {X} = state.flags

Base.show(io::IO, state::State) = print(io, "State($(state.id))")