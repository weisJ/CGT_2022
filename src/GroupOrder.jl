"""
    is_group_infinite(rws::RewritingSystem)
Determine whether the group defined by the rewriting system 'rws' is infinite or not.
"""
function is_group_infinite(rws::RewritingSystem)
    A = trimmification(complement(IndexAutomaton(rws)))
    return contains_loop_with_non_trivial_signature(A)
end