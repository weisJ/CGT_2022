abstract type AbstractState end

abstract type AbstractAutomaton{S<:AbstractState,X} end

"""
    alphabet(A::AbstractAutomaton{S,X})
Returns the alphabet of `A` i.e. an `AbstractVector{X}` of all allowed letters.
"""
function alphabet(::AbstractAutomaton) end

"""
	hasedge(A::AbstractAutomaton{S,X}, σ, label)
Check if `A` contains an edge starting at `σ` labeled by `label`
"""
function has_edge(::AbstractAutomaton{S,X},  label::X, state::S) where {S,X} end

"""
    edges(A::AbstractAutomaton{S,X}, σ)
Returns all edges in `A`, which start at `σ`. Ad edge is represented by
a pair `(l,τ)` where `l` is the label and `τ` the target of the edge.
"""
function edges(::AbstractAutomaton{S,X}, state::S) where {S,X} end

"""
	trace(A::AbstractAutomaton, label, σ)
Return `τ` if `(σ, label, τ)` is in `A`, otherwise return nothing.
"""
function trace(::AbstractAutomaton{S,X}, label::X, state::S) where {S,X} end

"""
	initial(A::AbstractAutomaton{S,X})
Returns an initial `state::S` of `A`.
"""
function initial(::AbstractAutomaton) end

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
    create_state(A::AbstractAutomaton{S,X})
Creates a new state suitable for the automaton `A` i.e. of type `S`.
The state will be detached and not connected to any other state in the state.
It will not be added to the automaton.
"""
function create_state(::AbstractAutomaton{S,X}) where {S,X} end

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