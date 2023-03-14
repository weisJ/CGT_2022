This project provides an implementation of general constructions on automata.
Together with the implementation of index automata this can be used to determined whether a group/monoid represented by a rewriting system is finite or infinite.

The project generally aims to avoid copying the automaton for the constructions. Instead it opts to wrap the input automaton if possible acting as a facade around it.

Concretely the project provides the following types and constructions:

- `AbstractAutomaton.jl`
  Defines the abstract type `AbstractAutomaton` on which all constructons will be performed on.
  Generally one shouldn't assume that an `AbstractAutomaton` is deterministic, as
  various provided operations don't produce deterministic automata.

- `Automaton.jl`, `State.jl`
  An concrete implementation `Automaton` of `AbstractAutomaton` which can be used to
  construct an explicit automaton by defining it's {initial,terminal} states and edges.
  There is no assumption about automatons being deterministic. Edges are allowed to be labeled by the empty word `ϵ` and multiple edges with the same label can occure.

  Though if one knows that the automaton will be deterministic a more efficient implementation could be used (which would probably closely follow the `Automaton` implementation above).

- `StateIterator.jl`
  An abstract type used for iterating/traversing over/through a given automaton.
  Due to the recusrive nature of graph exploration this can't be a plain iterator as one usually wants to have more fine grained control over which parts of the automaton are explored together with different actions before and after child states are explored.

- `EpochIterator.jl
  The implementation of `StateIterator` used for `Automaton`. It uses `epochs` to invalidate any previous traversals without having to do manual cleanup. This is the only (effective) implementation of `StateIterator`. The abstract type is provided nonetheless as other automaton implementations (e.g. using transition matrices) may wan't to use different ways of iteratons.

- `Alphabet.jl`
  This is generally the implementation from class with the difference, that it provides some additional helper methods to deal with the existence of `ϵ`. Inp articular it defines the `Label{X}` type, which can either be `ϵ` or an letter the alphabet.

- `AutomatonWrapper.jl`
  A simple helper type to delegate the implementation of the  `AbstractAutomaton` interface to some inner automaton object.

- `Complement.jl`
  Implementens the complement construction on automata

- `Completion.jl`
  Implementens the construction, which makes an automaton complete by adjoining an additional error state.

- `Intersection.jl`
  Implementens the construction of an automaton accepting the intersection of languages accepted by two automata.

- `Union.jl`
  Implementens the construction of an automaton accepting the union of languages accepted by two automata.

- `Deterministic.jl`
  Implements the subset construction turning a non-deterministic automaton into a deterministic one.

- `SubAutomaton.jl`
  Implements the subautomaton induced by a given subset of states.

- `Accessible.jl`
  Implements routines to find all (co)accessible and trim states of an automaton together with the trimmification of an automaton.

- `Loop.jl`
  Implements a loop finding routine automata which determines whether a loop with non-trivial signature exists.

- `IndexAutomaton.jl`
  Implementation of index automata from the class adjusted to work with the automaton interface from this project.

- `GroupOrder.jl`
  The actual implementation of determining whether a rewriting system describes an infinite group/monoid.

- `AbstractWord.jl`, `Word.jl`, `Orderings.jl`, `Rewrite.jl`, `RewritingSystem.jl`, `KnuthBendix.jl` are the respective implementations from the class.