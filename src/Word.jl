struct Word{T} <: AbstractWord{T}
    letters::Vector{T}
end

# AbstractWord interface
Word(v::AbstractVector{T}) where {T} = Word{T}(v)

Base.one(::Type{Word{T}}) where {T} = Word(Vector{T}())
Base.resize!(w::Word{T}, n) where {T} = resize!(w.letters, n)

import Base.append!
import Base.prepend!
import Base.popfirst!

Base.popfirst!(w::Word{T}) where {T} = popfirst!(w.letters)
Base.prepend!(w::Word{T}, v::Word{T}) where {T} = prepend!(w.letters, v.letters)
Base.append!(w::Word{T}, v::Word{T}) where {T} = append!(w.letters, v.letters)

# Implement abstract Vector interface
Base.size(w::Word) = size(w.letters)
Base.@propagate_inbounds Base.getindex(w::Word, i::Int) = w.letters[i]
Base.@propagate_inbounds function Base.setindex!(w::Word, value, idx::Int)
    return w.letters[idx] = value
end
