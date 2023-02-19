function collect_accessible_states!(A::AbstractAutomaton{S,X}, α::S, accessible::Set{S}) where {S,X}
    push!(accessible, α)
    for (_, σ) ∈ edges(A, α)
        σ ∈ accessible && continue
        collect_accessible_states!(A, σ, accessible)
    end
end

function accessible_states(A::AbstractAutomaton{S,X}) where {S,X}
    accessible = Set{S}()
    for α ∈ initial_states(A)
        collect_accessible_states!(A, α, accessible)
    end
    return accessible
end

function partial_find_path!(
    A::AbstractAutomaton{S,X},
    path::AbstractVector{S},
    stop::Set{S},
    viable_states::Set{S},
    non_viable_states::Set{S}
) where {S,X}
    α = last(path)
    α ∈ stop && return true
    for (_, σ) ∈ edges(A, α)
        # This indicates that a previous call revealed stop states aren't reachable from σ.
        # Hence we don't need to traverse this subtree any further.
        # However we may reach out destination with another edge, hence can't bail here.
        σ ∈ non_viable_states && continue
        # We have reached a node of which we know we can reach the stop nodes.
        # As we only need to mark the "undiscovered" nodes we can stop at this point.
        σ ∈ viable_states && return true
        push!(path, σ)
        partial_find_path!(A, path, stop, viable_states, non_viable_states) && return true
        pop!(path, σ)
    end
    return false
end


# TODO: Implement this using union find
# 1. Trace depth first through all(!) states determining their path component.
# 2. Trim states are the states, which have an initial and a terminal state in their component.

function coaccessible_states(A::AbstractAutomaton{S,X}, states=states(A)) where {S,X}
    coaccessible = Set{S}()
    non_coaccessible = Set{S}()
    terminal = convert(Set{S}, terminal_states(A))
    for σ ∈ states
        σ ∈ non_coaccessible && continue
        σ ∈ coaccessible && continue
        path = [σ]
        if partial_find_path!(A, path, terminal, coaccessible, non_coaccessible)
            for p ∈ path
                push!(coaccessible, p)
            end
        else
            # Mark all states reachable from σ as not being coaccessible.
            # Otherwise we would have found that σ is already coaccessible.
            collect_accessible_states!(A, σ, non_coaccessible)
        end
    end
    return coaccessible
end

function trim_states(A::AbstractAutomaton{S,X}) where {S,X}
    accessible = accessible_states(A)
    return coaccessible_states(A, accessible)
end
