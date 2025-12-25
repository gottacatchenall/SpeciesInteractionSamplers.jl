"""
    Pipeline operator for chaining transformations.
"""
Base.:(|>)(layer::NetworkLayer{Feasible}, context::SpatiotemporalContext) =
    possibility(layer, context)

Base.:(|>)(layer::NetworkLayer{Potential}, model::RealizationModel) =
    realize(layer, model)

Base.:(|>)(layer::NetworkLayer{Realized}, model::DetectabilityModel) =
    detect(layer, model)


"""
    sample_network(; generator, context, realization, detection, kwargs...)

Complete pipeline from metaweb to detected network.
"""    
function sample_network(;
    species = UnipartiteSpeciesPool(10),
    generator::NetworkGenerator,
    context::SpatiotemporalContext,
    realization::RealizationModel,
    detection::DetectabilityModel,
    return_all_stages::Bool=false
)
    feasible = generate(generator, species)
    potential = possibility(feasible, context)
    realized = realize(potential, realization)
    detected = detect(realized, detection)
    
    if return_all_stages
        return (
            feasible=feasible, 
            potential=potential, 
            realized=realized, 
            detected=detected
        )
    else
        return detected
    end
end

