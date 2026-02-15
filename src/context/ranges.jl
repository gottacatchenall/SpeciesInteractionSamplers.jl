
"""
    Ranges{T<:AbstractSpeciesTrait}
"""
struct Ranges{T<:AbstractSpeciesTrait}
    data::T
end
numspecies(r::Ranges) = numspecies(r.data)
Base.parent(r::Ranges) = parent(r.data)
Base.values(r::Ranges{<:PartitionedTrait}) = values(r.data)
Base.keys(r::Ranges{<:PartitionedTrait}) = keys(r.data)
Base.haskey(r::Ranges{<:PartitionedTrait}, k) = haskey(r.data, k)
Base.show(io::IO, ranges::Ranges{T}) where {T} = print(io, "Species Ranges in for $(numspecies(ranges)) species")
Base.getindex(r::Ranges{<:UnipartiteTrait}, species_name::Symbol) = r.data[species_name,:,:]
Base.getindex(r::Ranges{<:PartitionedTrait}, k) = r.data[k]

@testitem "Ranges" begin
    pool = UnipartiteSpeciesPool(3)
    ar = AutocorrelatedRange()
    ranges = generate(ar, pool, (8, 8))

    @test ranges isa Ranges
    @test numspecies(ranges) == 3
end
