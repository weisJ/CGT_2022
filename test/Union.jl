
@testset "Union" begin
    X = CGT.Alphabet([:a, :b])

    # Setup an automaton, which accept the Language {a^n | n ∈ N}
    An = CGT.Automaton(X)
    s = CGT.initial(An)
    t = CGT.add_state!(An)
    CGT.add_edge!(An, s, :a, t)
    CGT.add_edge!(An, t, :a, t)
    CGT.mark_terminal!(An, t)

    # Setup an automaton, which accept the Language {b^2n | n ∈ N}
    Bn = CGT.Automaton(X)
    s = CGT.initial(Bn)
    i = CGT.add_state!(Bn)
    t = CGT.add_state!(Bn)
    CGT.add_edge!(Bn, s, :b, i)
    CGT.add_edge!(Bn, i, :b, t)
    CGT.add_edge!(Bn, t, :b, i)
    CGT.mark_terminal!(Bn, t)

    @test CGT.accepts(An, [:a])
    @test CGT.accepts(An, [:a, :a, :a])
    @test !CGT.accepts(An, Symbol[])
    @test !CGT.accepts(An, [:b])
    @test !CGT.accepts(An, [:a, :b])
    @test !CGT.accepts(An, [:a, :b, :a])

    @test !CGT.accepts(Bn, [:b])
    @test CGT.accepts(Bn, [:b, :b])
    @test !CGT.accepts(Bn, [:b, :b, :b])
    @test CGT.accepts(Bn, [:b, :b, :b, :b])
    @test !CGT.accepts(Bn, Symbol[])
    @test !CGT.accepts(Bn, [:a])
    @test !CGT.accepts(Bn, [:a, :b])
    @test !CGT.accepts(Bn, [:b, :b, :a])

    C = CGT.UnionAutomaton(An, Bn)

    len = X -> length(collect(X))
    @test len(CGT.states(C)) == len(CGT.states(An)) + len(CGT.states(Bn))

    @test CGT.accepts(C, [:a])
    @test CGT.accepts(C, [:a, :a, :a])
    @test !CGT.accepts(C, Symbol[])
    @test !CGT.accepts(C, [:b])
    @test !CGT.accepts(C, [:a, :b])
    @test !CGT.accepts(C, [:a, :b, :a])
    @test !CGT.accepts(C, [:b])
    @test CGT.accepts(C, [:b, :b])
    @test !CGT.accepts(C, [:b, :b, :b])
    @test CGT.accepts(C, [:b, :b, :b, :b])

    C2 = CGT.SubsetConstructionAutomaton(C)

    @test CGT.accepts(C2, [:a])
    @test CGT.accepts(C2, [:a, :a, :a])
    @test !CGT.accepts(C2, Symbol[])
    @test !CGT.accepts(C2, [:b])
    @test !CGT.accepts(C2, [:a, :b])
    @test !CGT.accepts(C2, [:a, :b, :a])
    @test !CGT.accepts(C2, [:b])
    @test CGT.accepts(C2, [:b, :b])
    @test !CGT.accepts(C2, [:b, :b, :b])
    @test CGT.accepts(C2, [:b, :b, :b, :b])
end