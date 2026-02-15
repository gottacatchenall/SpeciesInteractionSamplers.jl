"""
    UnipartiteSpeciesPool
"""

struct UnipartiteSpeciesPool <: AbstractSpeciesPool
    species::SpeciesPartition
end
UnipartiteSpeciesPool(n::Int; kwargs...) = UnipartiteSpeciesPool(SpeciesPartition(n; kwargs...))

# Pass on methods to the single partition
Base.length(p::UnipartiteSpeciesPool) = length(p.species)
Base.eltype(p::UnipartiteSpeciesPool) = eltype(p.species)
Base.getindex(p::UnipartiteSpeciesPool, i) = getindex(p.species, i)
Base.iterate(p::UnipartiteSpeciesPool, state=1) = iterate(p.species, state)
Base.in(x::Symbol, p::UnipartiteSpeciesPool) = x in p.species

numspecies(p::UnipartiteSpeciesPool) = numspecies(p.species)
getspecies(p::UnipartiteSpeciesPool) = getspecies(p.species)
getspeciesaxis(p::UnipartiteSpeciesPool) = (species=getspecies(p),)

@testitem "UnipartiteSpeciesPool" begin
    # Integer constructor
    pool = UnipartiteSpeciesPool(5)
    @test numspecies(pool) == 5
    @test length(pool) == 5

    # Custom prefix
    pool2 = UnipartiteSpeciesPool(3; prefix=:bird)
    @test getspecies(pool2) == [:bird1, :bird2, :bird3]

    # From SpeciesPartition
    part = SpeciesPartition([:fox, :rabbit, :hawk])
    pool3 = UnipartiteSpeciesPool(part)
    @test numspecies(pool3) == 3
    @test getspecies(pool3) == [:fox, :rabbit, :hawk]

    # getspeciesaxis
    ax = getspeciesaxis(pool)
    @test ax isa NamedTuple
    @test haskey(ax, :species)
    @test ax.species == [:s1, :s2, :s3, :s4, :s5]
end
