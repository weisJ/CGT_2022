struct TaggedUnion{S1,S2}
    value::Union{S1,S2}
    tag::Bool
end

function left(::Type{S1}, ::Type{S2}, value::Union{S1,Nothing}) where {S1,S2}
    isnothing(value) && return nothing
    return TaggedUnion{S1,S2}(value, true)
end
function right(::Type{S1}, ::Type{S2}, value::Union{S2,Nothing}) where {S1,S2}
    isnothing(value) && return nothing
    return TaggedUnion{S1,S2}(value, false)
end

Base.:(==)(u1::TaggedUnion{S1,S2}, u2::TaggedUnion{S1,S2}) where {S1,S2} =
    u1.tag == u2.tag && (u1.value == u2.value)
Base.hash(u::TaggedUnion{S1,S2}) where {S1,S2} = hash(u.value, hash(u.tag))
Base.show(io::IO, state::TaggedUnion{S1,S2}) where {S1,S2} =
    state.tag ? print(io, "A($(state.value))") : print(io, "B($(state.value))")

struct UnionAutomaton{S1,S2,X} <: AbstractAutomaton{TaggedUnion{S1,S2},X}
    A::AbstractAutomaton{S1,X}
    B::AbstractAutomaton{S2,X}

    function UnionAutomaton(
        A::AbstractAutomaton{S1,X},
        B::AbstractAutomaton{S2,X}
    ) where {S1,S2,X}
        @assert alphabet(A) == alphabet(B)
        return new{S1,S2,X}(A, B)
    end
end

alphabet(A::UnionAutomaton{S1,S2,X}) where {S1,S2,X} = alphabet(A.A)

function has_edge(A::UnionAutomaton{S1,S2,X}, state::TaggedUnion{S1,S2}, label::Label{X}) where {S1,S2,X}
    return if state.tag
        has_edge(A.A, state.value, label)
    else
        has_edge(A.B, state.value, label)
    end
end

function edge_list(A::UnionAutomaton{S1,S2,X}, state::TaggedUnion{S1,S2}, label::Label{X}) where {S1,S2,X}
    return if state.tag
        Iterators.map(s -> left(S1, S2, s), edge_list(A.A, state.value, label))
    else
        Iterators.map(s -> right(S1, S2, s), edge_list(A.B, state.value, label))
    end
end

function trace(A::UnionAutomaton{S1,S2,X}, label::Label{X}, state::TaggedUnion{S1,S2}) where {S1,S2,X}
    return if state.tag
        left(S1, S2, trace(A.A, label, state.value))
    else
        right(S1, S2, trace(A.B, label, state.value))
    end
end

states(A::UnionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.flatten((
        Iterators.map(s -> left(S1, S2, s), states(A.A)),
        Iterators.map(s -> right(S1, S2, s), states(A.B))
    ))

initial_states(A::UnionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.flatten((
        Iterators.map(s -> left(S1, S2, s), initial_states(A.A)),
        Iterators.map(s -> right(S1, S2, s), initial_states(A.B))
    ))

terminal_states(A::UnionAutomaton{S1,S2,X}) where {S1,S2,X} =
    Iterators.flatten((
        Iterators.map(s -> left(S1, S2, s), terminal_states(A.A)),
        Iterators.map(s -> right(S1, S2, s), terminal_states(A.B))
    ))

function is_terminal(A::UnionAutomaton{S1,S2,X}, state::TaggedUnion{S1,S2}) where {S1,S2,X}
    return if state.tag
        is_terminal(A.A, state.value)
    else
        is_terminal(A.B, state.value)
    end
end

struct UnionStateIterator{S1,S2} <: StateIterator{TaggedUnion{S1,S2}}
    itA::StateIterator{S1}
    itB::StateIterator{S2}
end

function set_mark!(it::UnionStateIterator{S1,S2}, A::UnionAutomaton{S1,S2,X}, state::TaggedUnion{S1,S2}, flag::Bool) where {S1,S2,X}
    if state.tag
        set_mark!(it.itA, A.A, state.value, flag)
    else
        set_mark!(it.itB, A.B, state.value, flag)
    end
end

function get_mark(it::UnionStateIterator{S1,S2}, A::UnionAutomaton{S1,S2,X}, state::TaggedUnion{S1,S2}) where {S1,S2,X}
    return if state.tag
        get_mark(it.itA, A.A, state.value)
    else
        get_mark(it.itB, A.B, state.value)
    end
end

function traverse(
    A::UnionAutomaton{S1,S2,X},
    α::TaggedUnion{S1,S2},
    it::UnionStateIterator{S1,S2};
    enter::F1,
    exit::F2=s::TaggedUnion{S1,S2} -> Continue,
    edge_filter::F3=(_, _) -> true
) where {S1,S2,X,F1,F2,F3}
    return if α.tag
        traverse(A.A, α.value, it.itA;
            enter=s -> enter(left(S1, S2, s)),
            exit=s -> exit(left(S1, S2, s)),
            edge_filter=(l, s) -> edge_filter(l, exit(left(S1, S2, s))))
    else
        traverse(A.A, α.value, it.itA;
            enter=s -> enter(right(S1, S2, s)),
            exit=s -> exit(right(S1, S2, s)),
            edge_filter=(l, s) -> edge_filter(l, exit(right(S1, S2, s))))
    end
end

state_iterator(A::UnionAutomaton{S1,S2,X}; complete_loops::Bool=false) where {S1,S2,X} =
    UnionStateIterator(state_iterator(A.A; complete_loops), state_iterator(A.B; complete_loops))
