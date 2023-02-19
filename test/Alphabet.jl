@testset "Alphabet" begin
    X = CGT.Alphabet([:a, :b])

    @test typeof(X) == CGT.Alphabet{typeof(:a)}
    @test collect(X) == [:a, :b]
end