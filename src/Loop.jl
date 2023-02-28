_mark_in_current_path!(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, seen::Bool) where {S,X} =
    set_mark!(it, A, state, seen)
_is_in_current_path(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S) where {S,X} =
    get_mark(it, A, state) == true

function contains_loop_with_non_trivial_support(A::AbstractAutomaton{S,X}, α::S, it::StateIterator{S}) where {S,X}
    path = Label{X}[]
    found_non_trivial_loop = false
    traverse(A, α, it;
        enter=s -> begin
            found_non_trivial_loop && return Break
            _mark_in_current_path!(it, A, s, true)
            return Continue
        end,
        exit=s -> begin
            _mark_in_current_path!(it, A, s, false)
            if !isempty(path)
                pop!(path)
            end
        end,
        edge_filter=(l, s) -> begin
            if _is_in_current_path(it, A, s)
                # We are in a loop
                for label ∈ path
                    # Check whether a letter in the path is non-trivial
                    if label != ϵ
                        found_non_trivial_loop = true
                        break
                    end
                end
                # The loop is trivial. Just continue the search.
            end
            push!(path, l)
            return true
        end)
    return !isempty(path)
end

function contains_loop_with_non_trivial_support(A::AbstractAutomaton{S,X}) where {S,X}
    # Reuse the iterator as any loop which incorporates previously encountered states from other
    # initial states, would have resolved to a loop earlier.
    it = state_iterator(A; complete_loops=true)
    for α ∈ initial_states(A)
        contains_loop_with_non_trivial_support(A, α, it) && return true
    end
    return false
end