struct Alphabet{X}
    letters::Vector{X}
    indices::Dict{X,Int}

    function Alphabet(letters::Vector{X}) where {X}
        indices = Dict{X,Int}()
        for (i, x) ∈ enumerate(letters)
            indices[x] = i
        end
        return new{X}(letters, indices)
    end
end

letters(A::Alphabet) = A.letters
indexof(A::Alphabet{X}, x::Label{X}) where {X} = A.indices[x]
Base.length(A::Alphabet) = length(A.letters)

Base.iterate(A::Alphabet) = iterate(A.letters)
Base.iterate(A::Alphabet, state) = iterate(A.letters, state)