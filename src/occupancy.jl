struct Occurrence{T<:Union{Range,Phenology}}
    species::Vector{Symbol}
    occurrence::Vector{T}
end
Base.eachindex(occ::Occurrence{<:Phenology}) = eachindex(occurrence(occ)[begin])
Base.eachindex(occ::Occurrence{<:Range}) = CartesianIndices(occurrence(occ)[begin])
Base.size(occ::Occurrence) = size(occurrence(occ)[begin])
occurrence(occ::Occurrence) = occurrence.(occ.occurrence)

function present(occ::Occurrence{R}, idx) where {R<:Range}
    rangemaps = occurrence(occ)
    occ.species[findall([r[idx] > 0 for r in rangemaps])]
end

function present(occ::Occurrence{P}, idx) where {P<:Phenology}
    timeseries = occurrence(occ)
    occ.species[findall([t[idx] > 0 for t in timeseries])]
end


function generate(
    gen::Union{RG,PG},
    n::I
) where {I<:Integer,RG<:RangeGenerator,PG<:PhenologyGenerator}
    return Occurrence(
        map(i -> Symbol("node_$i"), 1:n),
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

