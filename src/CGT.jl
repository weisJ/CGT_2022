module CGT

using CatViews
using StaticArrays

include("Alphabet.jl")
include("AbstractAutomaton.jl")
include("StateIterator.jl")
include("State.jl")
include("EpochIterator.jl")
include("Automaton.jl")
include("AutomatonWrapper.jl")
include("Complement.jl")
include("Completion.jl")
include("SubAutomaton.jl")
include("Accessible.jl")

end
