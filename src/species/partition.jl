
"""
    SpeciesPartition{S,T}

A concrete collection of species names and associated metadata/traits.

# Fields
- `names::Vector{S}`: The unique identifiers for species in this partition.
- `traits::T`: Optional container for traits
- `metadata::Dict{Symbol, Any}`: Additional metadata for the partition.
"""
struct SpeciesPartition{S,T} 
    names::Vector{S}
    traits::T
    metadata::Dict{Symbol, Any}
end

# Constructors  
function SpeciesPartition(names::Vector{S}; traits=missing, metadata=Dict{Symbol,Any}()) where {S<:Union{Symbol, String}}
    SpeciesPartition(names, traits, metadata)
end

function SpeciesPartition(n::Int; prefix=:s, traits=missing, metadata=Dict{Symbol,Any}())
    names = [Symbol("$prefix$i") for i in 1:n]
    SpeciesPartition(names, traits, metadata)
end


# Base methods for Partition
Base.length(p::SpeciesPartition) = length(p.names)
Base.eltype(::SpeciesPartition{S}) where S = S
Base.getindex(p::SpeciesPartition, i) = p.names[i]
Base.iterate(p::SpeciesPartition, state=1) = iterate(p.names, state)
Base.in(x::Symbol, p::SpeciesPartition) = x in p.names

getspecies(p::SpeciesPartition) = p.names
getspeciesaxis(p::SpeciesPartition, name) = NamedTuple{Tuple((name,))}((getspecies(p),))


numspecies(p::SpeciesPartition) = length(p)

function Base.show(io::IO, p::SpeciesPartition)
    print(io, "SpeciesPartition with $(length(p)) species")
end

@testitem "SpeciesPartition constructors" begin
    # From integer count
    p = SpeciesPartition(5)
    @test length(p) == 5

    # Custom prefix
    p2 = SpeciesPartition(3; prefix=:plant)
    @test p2.names == [:plant1, :plant2, :plant3]

    # From names
    p3 = SpeciesPartition([:a, :b, :c])
    @test length(p3) == 3
    @test p3.names == [:a, :b, :c]
end

@testitem "SpeciesPartition Base methods" begin
    p = SpeciesPartition([:a, :b, :c, :d])

    @test length(p) == 4
    @test numspecies(p) == 4
    @test getspecies(p) == [:a, :b, :c, :d]
end

