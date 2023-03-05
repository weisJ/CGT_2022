mutable struct IndexData{X}
    prefix_length::Int
    value::Rule

    IndexData{X}(prefix_length::Int) where {X} = new{X}(prefix_length)
end

struct IndexAutomaton{X} <: AutomatonWrapper{State{X},X}
    A::Automaton{X}
    index_data::Dict{State{X}, IndexData{X}}

    IndexAutomaton(A::Automaton{X}) where {X} = new{X}(A, Dict{State{X},IndexData{X}}())
end

wrappee(idxA::IndexAutomaton{X}) where {X} = idxA.A

function add_state!(A::IndexAutomaton{X}, index_data::IndexData{X}) where {X}
    s = add_state!(A.A)
    A.index_data[s] = index_data
    return s
end

function add_edge!(A::IndexAutomaton{X}, source::State{X}, label::Label{X}, target::State{X}) where {X}
    add_edge!(A.A, source, label, target)
end

function direct_edges!(idxA::IndexAutomaton{X}, rwrules) where {X}
    @assert !isempty(rwrules)
    W = typeof(first(first(rwrules)))

    α = initial(idxA)
    idxA.index_data[α] = IndexData{X}(0)

    A = alphabet(idxA)
    n = length(A) # max_degree
    states_prefixes = [α => one(W)] # will be kept sorted
    for r in rwrules
        lhs, _ = r
        σ = α
        for (prefix_length, l) in enumerate(lhs)
            if !has_edge(idxA, σ, A[l])
                τ = add_state!(idxA, IndexData{X}(prefix_length))
                add_edge!(idxA, σ, A[l], τ)
                st_prefix = τ => lhs[1:prefix_length]
                # insert into sorted list
                k = searchsortedfirst(
                    states_prefixes,
                    st_prefix,
                    by=n -> idxA.index_data[first(n)].prefix_length
                )
                insert!(states_prefixes, k, st_prefix)
            end
            σ = trace(idxA, A[l], σ)
        end
        idxA.index_data[σ].value = r
        mark_terminal!(idxA.A, σ)
    end
    return idxA, states_prefixes
end


function skew_edges!(idxA::IndexAutomaton{X}, states_prefixes) where {X}
    # add missing loops at the root
    α = initial(idxA)
    A = alphabet(idxA)
    max_degree = length(A)
    if degree(α) ≠ max_degree
        for x in A
            if !has_edge(idxA, α, x)
                add_edge!(idxA, α, x, α)
            end
        end
    end

    # this has to be done in breadth-first fashion so that
    # trace(U, A) is defined
    if !issorted(states_prefixes, by=n -> idxA.index_data[first(n)].prefix_length)
        sort!(states_prefixes, by=n -> idxA.index_data[first(n)].prefix_length)
    end
    for (σ, prefix) in states_prefixes
        degree(σ) == max_degree && continue

        τ = let U = prefix[2:end]
            l, τ = trace_by_index_word(idxA, U)
            @assert l == length(U) # the whole U defines a path in A
            τ
        end

        for x in A
            has_edge(idxA, σ, x) && continue
            @assert has_edge(idxA, τ, x)
            add_edge!(idxA, σ, x, trace(idxA, x, τ))
        end
    end
    return idxA
end

function IndexAutomaton(R::RewritingSystem{W}) where {W}
    A = alphabet(R)
    indexA = IndexAutomaton(Automaton(A))
    append!(indexA, rwrules(R))
    return indexA
end

function append!(idxA::IndexAutomaton, rules)
    idxA2, signatures = direct_edges!(idxA, rules)
    return skew_edges!(idxA2, signatures)
end

function rewrite!(
	v::AbstractWord,
	w::AbstractWord,
	idxA::IndexAutomaton;
	path=[initial(idxA)]
)
    A = alphabet(idxA)
	resize!(v, 0)
	while !isone(w)
		x = popfirst!(w)
		σ = last(path) # current state
		τ = trace(idxA, A[x], σ) # next state
		@assert !isnothing(τ) "ia doesn't seem to be complete!; $σ"

		if is_terminal(idxA, τ)
			lhs, rhs = idxA.index_data[τ].value
			# lhs is a suffix of v·x, so we delete it from v
			resize!(v, length(v) - length(lhs) + 1)
			# now we need to rewind the path
			resize!(path, length(path) - length(lhs) + 1)
			# and prepend rhs to w
			prepend!(w, rhs)

			# @assert trace(v, ia) == (length(v), last(path))
		else
			push!(v, x)
			push!(path, τ)
		end
	end
	return v
end