module CGT

using CatViews
using StaticArrays
using DataStructures
using OrderedCollections

include("Alphabet.jl")
include("AbstractAutomaton.jl")
include("StateIterator.jl")
include("EpochIterator.jl")
include("State.jl")
include("Automaton.jl")
include("AutomatonWrapper.jl")
include("Complement.jl")
include("Completion.jl")
include("SubAutomaton.jl")
include("Accessible.jl")
include("Deterministic.jl")
include("Union.jl")
include("Intersection.jl")
include("Loop.jl")

end
