module CGT

using CatViews
using StaticArrays
using DataStructures
using OrderedCollections

include("Alphabet.jl")
include("AbstractWord.jl")
include("Word.jl")

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

include("Orderings.jl")
include("Rewrite.jl")
include("RewritingSystem.jl")
include("KnuthBendix.jl")
include("IndexAutomaton.jl")

include("GroupOrder.jl")

end
