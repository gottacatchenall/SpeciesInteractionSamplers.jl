
_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,<:Phenologies}
) =  @d metaweb.data .* context.ranges.data.data .* context.phenologies.data.data

_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,Missing}
) =  @d metaweb.data .* context.ranges.data.data 
_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{Missing,<:Phenologies}
) =  @d metaweb.data .* context.phenologies.data.data

_get_possibility(
    metaweb::NetworkLayer{Feasible,MultipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,<:Phenologies}
) = broadcast_dims(*, metaweb.data, values(context.ranges.data.dict)..., values(context.phenologies.data.dict)...)

_get_possibility(
    metaweb::NetworkLayer{Feasible,MultipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,Missing}
) = broadcast_dims(*, metaweb.data, values(context.ranges.data.dict)...)

_get_possibility(
    metaweb::NetworkLayer{Feasible,MultipartiteSpeciesPool},
    context::SpatiotemporalContext{Missing,<:Phenologies}
) = broadcast_dims(*, metaweb.data, values(context.phenologies.data.dict)...)


"""
    possibility(
        layer::NetworkLayer{Feasible}, 
        context::SpatiotemporalContext
    )

Transforms Feasible → Potential by applying co-occurrence filter.
"""
function possibility(
    metaweb::NetworkLayer{Feasible}, 
    context::SpatiotemporalContext
) 
    possible = _get_possibility(metaweb, context)
    NetworkLayer(
        Potential(),
        getspecies(metaweb),
        possible, 
        metaweb.metadata
    )
end 

"""
    possibility(
        layer::NetworkLayer{Feasible}, 
        context::SpatiotemporalContext
    )

Transforms Feasible → Potential by applying co-occurrence filter.
"""
function possibility(
    metaweb::NetworkLayer{Feasible}, 
    context::Missing
)  
    NetworkLayer(
        Potential(),
        getspecies(metaweb),
        metaweb.data, 
        metaweb.metadata
    )
end 
