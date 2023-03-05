@testset "Index rewrite" begin
    rws = let
        al = CGT.Alphabet([:a, :b, :A, :B])
        CGT.setinverse!(al, :a, :A)
        CGT.setinverse!(al, :b, :B)
        lenlex = CGT.LenLex(al, [:a, :A, :b, :B])

        a, b, A, B = (CGT.Word([i]) for i in 1:length(al))

        ε = one(a)
        rws = CGT.RewritingSystem(
            [a * A => ε, A * a => ε, b * B => ε, B * b => ε, b * a => a * b],
            lenlex
        )
        CGT.reduce(CGT.knuthbendix1(rws))
    end

    ia = CGT.IndexAutomaton(rws)
    n, l = (20, 200)

    for i in 1:n
        w = CGT.Word(rand(1:length(CGT.alphabet(rws)), l))
        @test CGT.rewrite(w, rws) == CGT.rewrite(w, ia)
    end
end