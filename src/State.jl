mutable struct State{X} <: AbstractState
    transitions::DefaultDict{Int,Vector{State{X}}}
    id::String
    flags::BitSet
    epochs::MVector{2,Int}

    State(A::T) where {X,T<:AbstractAutomaton{State{X},X}} =
        new{X}(
            DefaultDict{Int,Vector{State{X}}}(() -> Vector{State{X}}()),
            "s$(_safe_state_count(A) + 1)",
            BitSet(),
            @MVector [-1, -1])
end

Base.show(io::IO, state::State) = print(io, "State($(state.id))")