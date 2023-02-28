
@testset "Intersection" begin
    X = CGT.Alphabet([:a, :b])

    # Setup an automaton, which accept the Language {a^2n | n ∈ N}
    A = CGT.Automaton(X)
    s = CGT.initial(A)
    i = CGT.add_state!(A)
    t = CGT.add_state!(A)
    CGT.add_edge!(A, s, :a, i)
    CGT.add_edge!(A, i, :a, t)
    CGT.add_edge!(A, t, :a, i)
    CGT.mark_terminal!(A, t)

    # Setup an automaton, which accept the Language {a^3n | n ∈ N}
    B = CGT.Automaton(X)
    s = CGT.initial(B)
    i1 = CGT.add_state!(B)
    i2 = CGT.add_state!(B)
    t = CGT.add_state!(B)
    CGT.add_edge!(B, s, :a, i1)
    CGT.add_edge!(B, i1, :a, i2)
    CGT.add_edge!(B, i2, :a, t)
    CGT.add_edge!(B, t, :a, i1)
    CGT.mark_terminal!(B, t)

    runParityTest = (automaton, modulo) -> begin
        @test !CGT.accepts(automaton, [:b])
        @test !CGT.accepts(automaton, Symbol[])
        for i ∈ range(1, 13)
            X = repeat([:a], i)
            if i % modulo == 0
                @test CGT.accepts(automaton, X)
            else
                @test !CGT.accepts(automaton, X)
            end
        end
    end

    runParityTest(A, 2)
    runParityTest(B, 3)

    C = CGT.IntersectionAutomaton(A, B)

    runParityTest(C, 6)

    C2 = CGT.SubsetConstructionAutomaton(C)
    runParityTest(C2, 6)

end