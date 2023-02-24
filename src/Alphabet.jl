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

struct EmptyWord end
const ϵ = EmptyWord()
const Label = Union{X,EmptyWord} where {X}

letters(A::Alphabet) = A.letters
indexin(A::Alphabet{X}, x::X) where {X} = A.indices[x]
indexin(A::Alphabet{X}, x::Label{X}) where {X} = x == ϵ ? length(A) + 1 : indexin(A, x)

Base.length(A::Alphabet) = length(A.letters)

Base.iterate(A::Alphabet) = iterate(A.letters)
Base.iterate(A::Alphabet, state) = iterate(A.letters, state)

Base.:(==)(A::Alphabet, B::Alphabet) = A.letters == B.letters

function letters_with_epsilon(A::Alphabet{X}) where {X}
    eps::Vector{Label{X}} = [ϵ]
    return CatView(A.letters, eps)
end