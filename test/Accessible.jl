@testset "(Co)accssible states" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)
    s4 = CGT.add_state!(A)
    s5 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s1, :b, s3)
    CGT.add_edge!(A, s2, :b, s3)
    CGT.add_edge!(A, s2, :a, s4)
    CGT.add_edge!(A, s4, :a, s2)
    CGT.add_edge!(A, s5, :a, s4)

    CGT.mark_terminal!(A, s5)
    CGT.mark_terminal!(A, s2)

    accessible = CGT.accessible_states(A)

    @test s1 ∈ accessible
    @test s2 ∈ accessible
    @test s3 ∈ accessible
    @test s4 ∈ accessible
    @test !(s5 ∈ accessible)

    coaccessible = CGT.coaccessible_states(A)

    @test s1 ∈ coaccessible
    @test s2 ∈ coaccessible
    @test !(s3 ∈ coaccessible)
    @test s4 ∈ coaccessible
    @test s5 ∈ coaccessible

    trim = CGT.trim_states(A)

    @test s1 ∈ trim
    @test s2 ∈ trim
    @test !(s3 ∈ trim)
    @test s4 ∈ trim
    @test !(s5 ∈ trim)
end

@testset "Trimmification" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)
    s4 = CGT.add_state!(A)
    s5 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s1, :b, s3)
    CGT.add_edge!(A, s2, :b, s3)
    CGT.add_edge!(A, s2, :a, s4)
    CGT.add_edge!(A, s4, :a, s2)
    CGT.add_edge!(A, s5, :a, s4)

    CGT.mark_terminal!(A, s5)
    CGT.mark_terminal!(A, s2)

    B = CGT.trimmification(A)

    collected_states = Set(CGT.accessible_states(B, s1))
    real_states = Set(CGT.states(B))
    trim_states = Set(CGT.trim_states(A))

    @test trim_states == real_states
    @test collected_states == real_states
end

@testset "Non coaccesible states with loop" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)
    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)

    CGT.mark_terminal!(A, s1)
    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s1, :b, s3)
    CGT.add_edge!(A, s2, :a, s2)
    CGT.add_edge!(A, s2, :b, s3)
    CGT.add_edge!(A, s3, :a, s2)
    CGT.add_edge!(A, s3, :b, s3)

    accessible_states = CGT.accessible_states(A)

    @test s1 ∈ accessible_states
    @test s2 ∈ accessible_states
    @test s3 ∈ accessible_states

    coaccessible_states = CGT.coaccessible_states(A)

    @test s1 ∈ coaccessible_states
    @test !(s2 ∈ coaccessible_states)
    @test !(s3 ∈ coaccessible_states)
end