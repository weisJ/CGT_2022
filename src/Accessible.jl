function collect_accessible_states!(A::AbstractAutomaton{S,X}, α::S, accessible_states::Set{S}) where {S,X}
    push!(accessible_states, α)
    for (_, σ) ∈ edges(A, α)
        σ ∈ accessible_states && continue
        collect_accessible_states!(A, σ, accessible_states)
    end
end

function accessible_states(A::AbstractAutomaton{S,X}) where {S,X}
    accessible_states = Set{S}()
    for α ∈ initial_states(A)
        collect_accessible_states!(A, α, accessible_states)
    end
    return accessible_states
end
