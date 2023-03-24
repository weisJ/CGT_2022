function free_group_relations(order::Int)
    s = c -> Symbol(Char('a' + c))
    S = c -> Symbol(Char('A' + c))
    symbols_in_order = collect(Iterators.flatten([s(i), S(i)] for i in 0:order-1))
    al = CGT.Alphabet(symbols_in_order)
    for i in 0:order-1
        CGT.setinverse!(al, 2 * i + 1, 2 * i + 2)
    end
    lenlex = CGT.LenLex(al, symbols_in_order)

    ϵ = one(CGT.Word([1]))
    return (collect(Iterators.flatten([
            CGT.Word([2 * i + 1]) * CGT.Word([2 * i + 2]) => ϵ,
            CGT.Word([2 * i + 2]) * CGT.Word([2 * i + 1]) => ϵ
        ] for i in 0:order-1)),
        lenlex)
end

function free_group_rewriting_system(order::Int)
    rel, lenlex = free_group_relations(order)
    rws = CGT.RewritingSystem(rel, lenlex)
    return CGT.reduce(CGT.knuthbendix1(rws))
end

@testset "Free groups are infinite" begin
    for n in 1:20
        @test CGT.is_group_infinite(free_group_rewriting_system(n)) == true
    end
end

function cyclic_group_rewriting_system(order::Int)
    rel, lenlex = free_group_relations(1)

    a = CGT.Word([1])
    ϵ = one(a)
    push!(rel, a^order => ϵ)

    rws = CGT.RewritingSystem(rel, lenlex)
    return CGT.reduce(CGT.knuthbendix1(rws))
end

@testset "Check finite cyclic groups are finite" begin
    for n in 1:20
        @test CGT.is_group_infinite(cyclic_group_rewriting_system(n)) == false
    end
end

@testset "Example from Lecture" begin
    rws = let
        A = CGT.Alphabet([:a,:b])
        lenlex = CGT.LenLex(A, [:a,:b])
        a = CGT.Word([1])
        b = CGT.Word([2])
        ϵ = one(a)
        rws = CGT.RewritingSystem([
            a^3 => ϵ,
            b^3 => ϵ,
            b*a*b*a => a^2*b^2,
            b^2*a^2 => a*b*a*b
        ], lenlex)
        CGT.reduce(CGT.knuthbendix1(rws))
    end
    @test CGT.is_group_infinite(rws) == true
end