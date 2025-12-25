
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
