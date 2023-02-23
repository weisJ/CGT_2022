mutable struct EpochFlags{N}
    flags::BitSet
    epochs::MVector{N,Int}

    EpochFlags{N}() where {N} = new{N}(BitSet(), @MVector [-1, -1])
end

function set_flag!(epoch::EpochFlags{N}, current_epoch::Int, flag::Int, value::Bool) where {N}
    @assert flag >= 1 && flag <= N
    epoch.epochs[flag] = current_epoch
    if value
        push!(epoch.flags, flag)
    else
        delete!(epoch.flags, flag)
    end
end

function get_flag(epoch::EpochFlags{N}, current_epoch::Int, flag::Int) where {N}
    @assert flag >= 1 && flag <= N
    epoch.epochs[flag] == current_epoch || return nothing
    return flag ∈ epoch.flags
end

const SeenFlag = 1
const MarkFlag = 2

mutable struct State{X} <: AbstractState
    transitions::DefaultDict{Int,Vector{State{X}}}
    id::String
    epoch::EpochFlags{2}

    State(A::T) where {X,T<:AbstractAutomaton{State{X},X}} =
        new{X}(
            DefaultDict{Int,Vector{State{X}}}(() -> Vector{State{X}}()),
            "s$(_safe_state_count(A) + 1)",
            EpochFlags{2}())
end

Base.show(io::IO, state::State) = print(io, "State($(state.id))")