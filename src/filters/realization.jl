
"""
    MassActionRealization

    Realized interactions follow a Poisson process: ζᵢⱼ ~ Poisson(θᵢⱼ) where the rate θᵢⱼ is a function of 
    the abundance of the species involved in the interaction.
"""
struct MassActionRealization{T,A,R} <: RealizationModel
    energy::T  # Can be scalar, or array matching dimensions
    abundance::A
    combination_mode::R
end

MassActionRealization(abundance; energy=1.0, combination_mode=AbundanceProduct()) = MassActionRealization(energy, abundance, combination_mode)

# Unipartite 
function _get_rate_matrix(
    layer::NetworkLayer{T, UnipartiteSpeciesPool}, 
    mass_action::MassActionRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, mass_action.energy
    abundance = mass_action.abundance.data.data
    abundance2 = set(abundance, :species=>:species2)
    rate = @d possible .* broadcast_dims(mass_action.combination_mode, abundance, abundance2)
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=(1,2)), rate.dims)

    return normalized_rate
end 

# Multipartite 
function _get_rate_matrix(
    layer::NetworkLayer{T, BipartiteSpeciesPool}, 
    mass_action::MassActionRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, mass_action.energy

    pairwise_abundance_rates = broadcast_dims(mass_action.combination_mode, collect(values(mass_action.abundance.data.dict))...)
    rate = @d possible .* pairwise_abundance_rates

    # NOTE: this normalizes across all partitions. perhaps kwarg to do each partition separate?
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=1:numpartitions(layer.species)), rate.dims)
    return normalized_rate
end


"""
    realize(
        layer::NetworkLayer{Potential}, 
        model::RealizationModel
    )

Transforms Potential → Realized via stochastic process.

ζᵢⱼ ~ Poisson(θᵢⱼ) for locations/times where γᵢⱼ = true
"""

function realize(
    layer::NetworkLayer{T}, 
    model::MassActionRealization
) where {T<:Union{Feasible,Potential}}
    rate = _get_rate_matrix(layer, model)
    realized = map(x-> x > 0 ? rand(Poisson(x)) : 0, rate)
    metadata = merge(layer.metadata, Dict(:realization_model => model))
    return NetworkLayer(Realized(), getspecies(layer), realized, metadata)
end

