
@testset "Subset construction" begin
    X = CGT.Alphabet([:a, :b])
    A = CGT.Automaton(X)

    q0 = CGT.initial(A)
    q1 = CGT.add_state!(A)
    q2 = CGT.add_state!(A)
    q3 = CGT.add_state!(A)
    q4 = CGT.add_state!(A)

    CGT.add_edge!(A, q0, :a, q1)
    CGT.add_edge!(A, q0, CGT.ϵ, q3)

    CGT.add_edge!(A, q1, :b, q2)

    CGT.add_edge!(A, q2, :a, q0)
    CGT.add_edge!(A, q2, :b, q0)

    CGT.add_edge!(A, q3, :a, q4)
    CGT.add_edge!(A, q3, :b, q4)

    CGT.add_edge!(A, q4, :b, q3)

    CGT.mark_terminal!(A, q3)

    states = CGT.states(A)
    testClosure = (start_states, expected) -> begin
        closure = CGT.epsilon_closure(A, states, start_states)
        @test Set(CGT.contained_states(states, closure)) == Set(expected)
    end

    testClosure([q0], [q0, q3])
    testClosure([q1], [q1])
    testClosure([q2], [q2])
    testClosure([q0, q4], [q0, q3, q4])

    states_set = Set(states)
    for s ∈ states
        for (_,σ) ∈ CGT.edges(A, s)
            @test σ ∈ states_set
        end
    end

    B = CGT.SubsetConstructionAutomaton(A)

    @test length(CGT.initial_states(A)) == 1
    @test CGT.is_deterministic(B)
    @test length(CGT.states(B)) == 7
end