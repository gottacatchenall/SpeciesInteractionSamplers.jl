"""
    Phenologies{T<:AbstractSpeciesTrait}
"""
struct Phenologies{T<:AbstractSpeciesTrait}
    data::T
end
numspecies(p::Phenologies) = numspecies(p.data)
Base.parent(p::Phenologies) = parent(p.data)
Base.values(p::Phenologies{<:PartitionedTrait}) = values(p.data)
Base.keys(p::Phenologies{<:PartitionedTrait}) = keys(p.data)
Base.haskey(p::Phenologies{<:PartitionedTrait}, k) = haskey(p.data, k)
Base.getindex(p::Phenologies{<:PartitionedTrait}, k) = p.data[k]
Base.show(io::IO, phenologies::Phenologies{T}) where {T} = print(io, "Species Phenologies for N timepoints for $(numspecies(phenologies)) species")

@testitem "Phenologies constructor" begin
    pool = UnipartiteSpeciesPool(4)
    gen = UniformPhenology()
    phens = generate(gen, pool, 10)

    @test phens isa Phenologies
    @test numspecies(phens) == 4
end
