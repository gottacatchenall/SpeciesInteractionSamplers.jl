"""
    Occurrence{T<:Union{Range,Phenology}}

A set of either [`Range`](@ref)s or [`Phenology`](@ref)s for each species in a [`SpeciesPool`](@ref).
"""
struct Occurrence{T<:Union{Range,Phenology}}
    species::SpeciesPool
    occurrence::Vector{T}
end
Base.eachindex(occ::Occurrence{<:Phenology}) = eachindex(occurrence(occ)[begin])
Base.eachindex(occ::Occurrence{<:Range}) = CartesianIndices(occurrence(occ)[begin])
Base.size(occ::Occurrence) = size(occurrence(occ)[begin])

#TODO: `occurrence` as a getter for both (that accesses a field with a diff name!) is ambiguous and should be fixed
occurrence(occ_set::Occurrence) = occurrence.(occ_set.occurrence)


# HACK: need to think through methods for occurrence retrieval more, this is unclear to read
present(occ::Occurrence, idx) = occ.species[findall([r[idx] > 0 for r in occurrence(occ)])]

"""
    generate(gen::Union{RG,PG}, n::I) where {I<:Integer,RG<:RangeGenerator,PG<:PhenologyGenerator}

Generates a set `n` [`Occurrence`](@ref)s based on the input generator `gen`. 
"""
function generate(
    gen::Union{RG,PG},
    n::I
) where {I<:Integer,RG<:RangeGenerator,PG<:PhenologyGenerator}
    return Occurrence(
        SpeciesPool(map(i -> Symbol("node_$i"), 1:n)),
        map(_ -> generate(gen), 1:n)
    )
end

Base.show(io::IO, occ::Occurrence{<:Range}) = begin
    sp_richness = sum(occurrence(occ))
    p = UnicodePlots.heatmap(
        sp_richness,
        xlabel="x",
        ylabel="y",
        zlabel="Richness"
    )
    print(io, p)
end

Base.show(io::IO, occ::Occurrence{<:Phenology}) = begin
    phen = sum(occurrence(occ))
    p = UnicodePlots.lineplot(
        phen,
        xlabel="time",
        ylabel="richness",
    )
    print(io, p)
end

