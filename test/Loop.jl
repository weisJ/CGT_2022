
@testset "Find loops" begin
    X = CGT.Alphabet([:a, :b])

    A = CGT.Automaton(X)
    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)
    s3 = CGT.add_state!(A)
    s4 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, CGT.ϵ, s2)
    CGT.add_edge!(A, s2, CGT.ϵ, s3)
    CGT.add_edge!(A, s3, CGT.ϵ, s1)

    CGT.add_edge!(A, s2, :a, s4)

    @test !CGT.contains_loop_with_non_trivial_support(A)

    CGT.add_edge!(A, s2, :a, s3)
    @test CGT.contains_loop_with_non_trivial_support(A)
end

@testset "Self loop is detected" begin
    X = CGT.Alphabet([:a])
    A = CGT.Automaton(X)
    s1 = CGT.initial(A)
    s2 = CGT.add_state!(A)

    CGT.add_edge!(A, s1, :a, s2)
    CGT.add_edge!(A, s2, :a, s2)

    @test CGT.contains_loop_with_non_trivial_support(A)
end