@testset "Automaton Basics" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s2, :b, s3)

    @test CGT.alphabet(A) == X

    @test CGT.has_edge(A, s1, :a)
    @test !CGT.has_edge(A, s1, :b)

    @test CGT.trace(A, :b, s2) == s3
    @test isnothing(CGT.trace(A, :a, s3))
    @test isnothing(CGT.trace(A, :b, s3))
    @test CGT.trace(A, [:a, :b], s1) == (2, s3)
end

@testset "Complement" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s2, :b, s3)

    CGT.mark_terminal!(A, s3)
    CGT.mark_terminal!(A, s2)

    B = CGT.complement(A)

    @test CGT.alphabet(B) == X

    @test CGT.has_edge(B, s1, :a)
    @test !CGT.has_edge(B, s1, :b)

    @test CGT.trace(B, :b, s2) == s3
    @test isnothing(CGT.trace(A, :a, s3))
    @test isnothing(CGT.trace(A, :b, s3))
    @test CGT.trace(B, [:a, :b], s1) == (2, s3)

    @test !CGT.is_terminal(A, s1)
    @test CGT.is_terminal(A, s2)
    @test CGT.is_terminal(A, s3)

    @test CGT.is_terminal(B, s1)
    @test !CGT.is_terminal(B, s2)
    @test !CGT.is_terminal(B, s3)
end

@testset "Completion" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s2, :b, s3)

    CGT.mark_terminal!(A, s3)
    CGT.mark_terminal!(A, s2)

    B = CGT.completion(A)

    @test CGT.alphabet(B) == X
    @test CGT.is_complete(B)
end