abstract type AbstractAutomaton{S,X} end

"""
    alphabet(A::AbstractAutomaton{S,X})
Returns the alphabet of `A` i.e. an `Alphabet{X}` of all allowed letters.
"""
function alphabet(::AbstractAutomaton) end

"""
	hasedge(A::AbstractAutomaton{S,X}, σ, label)
Check if `A` contains an edge starting at `σ` labeled by `label`
"""
function has_edge(::AbstractAutomaton{S,X}, state::S, label::Label{X}) where {S,X} end

"""
    edges(A::AbstractAutomaton{S,X}, σ)
Returns all edges in `A`, which start at `σ`. An edge is represented by
a pair `(l,τ)` where `l` is the label and `τ` the target of the edge.
"""
function edges(A::AbstractAutomaton{S,X}, state::S) where {S,X}
    non_empty_edges = Iterators.filter(
        E -> !isnothing(E[2]),
        ((l, edge_list(A, state, l)) for l ∈ letters_with_epsilon(alphabet(A))))
    return Iterators.flatten(((l, τ) for τ ∈ E) for (l, E) ∈ non_empty_edges)
end

"""
    edge_list(A::AbstractAutomaton{S,X}, σ, l)
Returns all edges in `A`, which start at `σ` with label `l`.
"""
function edge_list(::AbstractAutomaton{S,X}, state::S, l::Label{X}) where {S,X} end

"""
	trace(A::AbstractAutomaton, label, σ)
Return `τ` if `(σ, label, τ)` is in `A`, otherwise return nothing.
"""
function trace(::AbstractAutomaton{S,X}, label::Label{X}, state::S) where {S,X} end

"""
	initial_states(A::AbstractAutomaton{S,X})
Returns a collection of the initial states of `A`.
"""
function initial_states(::AbstractAutomaton) end

"""
	initial_states(A::AbstractAutomaton{S,X})
Returns a collection of the terminal states of `A`.
"""
function terminal_states(::AbstractAutomaton) end

"""
    is_terminal(A::AbstractAutomaton{S,X}, label, σ)
Returns whether the state `σ` is terminal in `A`.
"""
function is_terminal(::AbstractAutomaton{S,X}, state::S) where {S,X} end

"""
	states(A::AbstractAutomaton{S,X})
Returns an `AbstractVector{S}` of all states in `A`.
"""
function states(::AbstractAutomaton{S,X}) where {S,X} end

"""
    state_iterator(A::AbstractAutomaton{S,X}, complete_loops::Bool=false)
Returns a `StateIterator{S}` suitable which can be used to iterate over all
states of the automaton `A`. If `complete_loops` is true the iterator will complete
all loops once by entering the initial state again.
"""
function state_iterator(::AbstractAutomaton{S,X}; complete_loops::Bool=false) where {S,X} end

"""
	initial(A::AbstractAutomaton{S,X})
Returns an initial `state::S` of `A`.
"""
initial(A::AbstractAutomaton{X,S}) where {X,S} = first(initial_states(A))

"""
	trace(A::AbstractAutomaton{S,X}, w::AbstractVector{<:X} [, σ=initial(A)])
Return a pair `(l, τ)`, where
 * `l` is the length of the longest prefix of `w` which defines a path starting at `σ` in `A` and
 * `τ` is the last state (node) on the path.
"""
function trace(A::AbstractAutomaton{S,X}, w::AbstractVector{X}, σ=initial(A)::S) where {X,S}
    for (i, l) in enumerate(w)
        if has_edge(A, σ, l)
            σ = trace(A, l, σ)
        else
            return i - 1, σ
        end
    end
    return length(w), σ
end

function trace_by_index_word(A::AbstractAutomaton{S,X}, w::AbstractVector{Int}, σ=initial(A)::S) where {X,S}
    alph = alphabet(A)
    for (i, l) in enumerate(w)
        letter = alph[l]
        if has_edge(A, σ, letter)
            σ = trace(A, letter, σ)
        else
            return i - 1, σ
        end
    end
    return length(w), σ
end


function accepts(A::AbstractAutomaton{S,X}, w::AbstractVector{X}) where {S,X}
    for α ∈ initial_states(A)
        i, σ = trace(A, w, α)
        if i == length(w) && is_terminal(A, σ)
            return true
        end
    end
    return false
end