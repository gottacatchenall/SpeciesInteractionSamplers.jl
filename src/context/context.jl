
"""
    SpatiotemporalContext

Holds the environmental constraints.

# Fields
- ... todo
"""
struct SpatiotemporalContext{R,P}
    ranges::R
    phenologies::P
    metadata::Dict{Symbol,Any}
end

Base.show(io::IO, context::SpatiotemporalContext{<:Ranges,Missing}) = print(io, 
    """
    Spatial Context
    """
)

Base.show(io::IO, context::SpatiotemporalContext{<:Ranges,<:Phenologies}) = print(io, 
    """
    Spatiotemporal Context
    """
)

Base.show(io::IO, context::SpatiotemporalContext{Missing,Missing}) = print(io, 
    """
    Topological Context
    """
)


numspecies(context::SpatiotemporalContext{<:Ranges,Missing}) = numspecies(context.ranges)
numspecies(context::SpatiotemporalContext{R,<:Phenologies}) where {R} = numspecies(context.phenologies)


# ====================================================================================
#
# Constructors 
#
# ====================================================================================

function SpatiotemporalContext(ranges::Ranges; metadata=Dict{Symbol,Any}())
    SpatiotemporalContext(ranges, missing, metadata)
end

function SpatiotemporalContext(phenology::Phenologies; metadata=Dict{Symbol,Any}())
    SpatiotemporalContext(missing, phenology, metadata)
end

function SpatiotemporalContext(ranges::Ranges, phenologies::Phenologies; metadata=Dict{Symbol,Any}())
    SpatiotemporalContext(ranges, phenologies, metadata)
end

@testitem "SpatiotemporalContext constructors" begin
    pool = UnipartiteSpeciesPool(4)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    phens = generate(UniformPhenology(), pool, 10)

    # Spatial only
    context_spatial = SpatiotemporalContext(ranges)
    @test context_spatial.ranges isa Ranges
    @test context_spatial.phenologies === missing
    @test numspecies(context_spatial) == 4

    # Temporal only
    context_temporal = SpatiotemporalContext(phens)
    @test context_temporal.ranges === missing
    @test context_temporal.phenologies isa Phenologies
    @test numspecies(context_temporal) == 4

    # Both
    context_full = SpatiotemporalContext(ranges, phens)
    @test context_full.ranges isa Ranges
    @test context_full.phenologies isa Phenologies
    @test numspecies(context_full) == 4

end
