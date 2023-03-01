struct Alphabet{X}
    letters::Vector{X}
    inverses::Vector{Int}
    indices::Dict{X,Int}

    function Alphabet(
        letters::Vector{X},
        inverses::AbstractVector{<:Integer}=zeros(Int, length(letters)),
    ) where {X}
        @assert length(letters) == length(inverses) "Non-compatible inverses specification"
        @assert all(>=(0), inverses) "Inverses must be non-negative"
        @assert !(X <: Integer) "Only non-integer letters are needed"
        @assert unique(letters) == letters "Non-unique letters are not supported"

        return new{X}(
            letters,
            inverses,
            Dict(l => i for (i, l) in pairs(letters))
        )
    end
end

struct EmptyWord end
const ϵ = EmptyWord()
const Label = Union{X,EmptyWord} where {X}

letters(A::Alphabet) = A.letters

function letters_with_epsilon(A::Alphabet{X}) where {X}
    eps::Vector{Label{X}} = [ϵ]
    return CatView(letters(A), eps)
end

indexin(A::Alphabet{X}, x::X) where {X} = A.indices[x]
indexin(A::Alphabet{X}, x::Label{X}) where {X} = x == ϵ ? length(A) + 1 : indexin(A, x)

Base.getindex(A::Alphabet{X}, letter::X) where {X} = indexin(A, letter)
Base.getindex(A::Alphabet{X}, index::Integer) where {X} = A.letters[index]

Base.:(==)(A::Alphabet{X}, B::Alphabet{X}) where {X} =
    A.letters == B.letters && A.inverses == B.inverses

Base.length(A::Alphabet) = length(A.letters)
Base.iterate(A::Alphabet) = iterate(A.letters)
Base.iterate(A::Alphabet, state) = iterate(A.letters, state)
Base.eltype(::Type{Alphabet{X}}) where {X} = X

hasinverse(A::Alphabet{X}, letter::X) where {X} = hasinverse(A, A[letter])
hasinverse(A::Alphabet{X}, index::Integer) where {X} = !iszero(A.inverses[index])

Base.inv(A::Alphabet{X}, letter::X) where {X} = A[inv(A, A[letter])]
function Base.inv(A::Alphabet{X}, index::Integer) where {X}
    hasinverse(A, index) ||
        throw(ArgumentError("Non-invertible letter: $(A[index])"))
    return A.inverses[index]
end

setinverse!(A::Alphabet{X}, y::X, Y::X) where {X} = setinverse!(A, A[y], A[Y])

function setinverse!(A::Alphabet{X}, y::Integer, Y::Integer) where {X}
    @assert !hasinverse(A, y) "Letter $(A[y]) already has inverse: $(inv(A, y))"
    @assert !hasinverse(A, Y) "Letter $(A[Y]) already has inverse: $(inv(A, Y))"

    A.inverses[y] = Y
    A.inverses[Y] = y

    return A
end


function Base.show(io::IO, A::Alphabet{X}) where {X}
    println(io, "Alphabet of $(eltype(A)) with $(length(A)) letters:")
    for letter in A
        print(io, A[letter], ".\t", letter)
        if hasinverse(A, letter)
            print(io, " with inverse ", inv(A, letter))
        end
        println(io, "")
    end
end