_mark_in_current_path!(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S, seen::Bool) where {S,X} =
    set_mark!(it, A, state, seen)
_is_in_current_path(it::StateIterator{S}, A::AbstractAutomaton{S,X}, state::S) where {S,X} =
    get_mark(it, A, state) == true

function contains_loop_with_non_trivial_support(A::AbstractAutomaton{S,X}, α::S, it::StateIterator{S}) where {S,X}
    path = Tuple{Label{X},S}[(ϵ, α)]
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
                if l != ϵ
                    found_non_trivial_loop = true
                else
                    for (i, (label, δ)) ∈ Iterators.reverse(enumerate(path))
                        if δ == s
                            # We have found the location where the loop closes on itself.
                            # If by now we haven't found a non-trivial edge there is none:
                            # As we detect loops as early as possible no further occurance of 's'
                            # can contribute to a non trivial loop, as it was checked beforehand.
                            #
                            # Searching further may bring is into a location in the path which doesn't
                            # belong to the path. Everything before this situation will belong to it thoug.
                            break
                        end

                        # Check whether a letter in the path is non-trivial
                        if label != ϵ
                            found_non_trivial_loop = true
                            break
                        end
                    end
                end
                # The loop is trivial. Just continue the search.
            end
            if !found_non_trivial_loop
                push!(path, (l, s))
            end
            return true
        end)
    return found_non_trivial_loop
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