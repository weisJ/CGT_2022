function accessible_states(A::AbstractAutomaton{S,X}, α::S; accumulator=Vector{S}()) where {S,X}
    traverse(A, α;
        enter=s::S -> begin
            push!(accumulator, s)
            return Continue
        end)
    return accumulator
end

function accessible_states(A::AbstractAutomaton{S,X}; accumulator=Vector{S}()) where {S,X}
    for α ∈ initial_states(A)
        accessible_states(A, α; accumulator)
    end
    return accumulator
end

_mark_coacessible!(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, coaccessible::Bool) where {S,X} =
    set_mark!(it, A, state, coaccessible)
_is_definitiely_coacessible(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S) where {S,X} =
    get_mark(it, A, state) == true
_is_definitiely_not_coacessible(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S) where {S,X} =
    get_mark(it, A, state) == false

function coaccessible_states(A::AbstractAutomaton{S,X}, states=states(A); accumulator=Vector{S}()) where {S,X}
    terminal = convert(Set{S}, terminal_states(A))
    it = state_iterator(A; complete_loops=true)
    for σ ∈ states
        path = S[]
        traverse(A, σ, it;
            enter=s::S -> begin
                # We encountered a state, which is coaccessible, hence we don't need
                # to explore any further.
                _is_definitiely_coacessible(it, A, s) && return Break
                _is_definitiely_not_coacessible(it, A, s) && return Break

                _mark_coacessible!(it, A, s, true)
                push!(path, s)

                # Mark the state as being coaccessible. If we don't find any terminal state
                # we will unset it in the `exit` call below.

                # We are actually coaccessible. Indicate that we don't want to traverse any further
                # This should result in `exit` not being called afterwards.
                if s ∈ terminal
                    return Break
                end

                return Continue
            end,
            exit=s::S -> begin
                _mark_coacessible!(it, A, s, false)
                if !isempty(path)
                    pop!(path)
                end
            end)
        if _is_definitiely_coacessible(it, A, σ)
            push!(accumulator, σ)
        end
    end
    return accumulator
end

function trim_states(A::AbstractAutomaton{S,X}; accumulator=Vector{S}()) where {S,X}
    return coaccessible_states(A, accessible_states(A); accumulator)
end

function trimmification(A::AbstractAutomaton{S,X}) where {S,X}
    return SubAutomaton(A, trim_states(A; accumulator=Set{S}()), false)
end
