
function redirect_terminal_cross_edges!(idxA::IndexAutomaton{X}) where {X}
    for s ∈ terminal_states(idxA)
        for (l, σ) ∈ edges(idxA, s)
            if σ != s
                remove_edge!(idxA.A, s, l, σ)
                add_edge!(idxA.A, s, l, s)
            end
        end
    end
end

function is_group_infinite(rws::RewritingSystem)
    idxA = IndexAutomaton(rws)
    # Note: IndexAutomaton is build such that rewrititng is possible.
    #       However this means that it technically isn't the automaton
    #       Recognizin the language of unreduced words as it is possible to
    #       transition from a terminal state to a non terminal under the assumption
    #       that a rewrite has occured.
    #       Instead we should stop once a terminal state has been found as that means
    #       a LHS of a rule appears as a subword. To this end we simply redirect all
    #       outgoing edges of terminal states to be loops to make them dead ends.
    redirect_terminal_cross_edges!(idxA)
    A = trimmification(complement(idxA))
    return contains_loop_with_non_trivial_support(A)
end