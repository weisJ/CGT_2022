@testset "Accssible states" begin
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
    CGT.add_edge!(A, s4, :a, s3)
    CGT.add_edge!(A, s5, :a, s4)

    accessible = CGT.accessible_states(A)

    @test s1 ∈ accessible
    @test s2 ∈ accessible
    @test s3 ∈ accessible
    @test s4 ∈ accessible
    @test !(s5 ∈ accessible)
end