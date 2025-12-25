
"""
    MassActionRealization

    Realized interactions follow a Poisson process: ζᵢⱼ ~ Poisson(θᵢⱼ) where the rate θᵢⱼ is a function of 
    the abundance of the species involved in the interaction.
"""
struct MassActionRealization{T,A,R} <: RealizationModel
    energy::T  # Can be scalar, or array matching dimensions
    abundance::A
    realization_mode::R
end

MassActionRealization(abundance; energy=1.0, realization_mode=AbundanceProduct()) = MassActionRealization(energy, abundance, realization_mode)

# Unipartite 
function _get_rate_matrix(
    layer::NetworkLayer{Potential, UnipartiteSpeciesPool}, 
    mass_action::MassActionRealization
)
    possible, energy = layer.data, mass_action.energy
    abundance = mass_action.abundance.data.data
    abundance2 = set(abundance, :species=>:species2)
    rate = @d energy .* possible .* broadcast_dims(mass_action.realization_mode, abundance, abundance2)
    return rate
end 

# Multipartite 
function _get_rate_matrix(
    layer::NetworkLayer{Potential, MultipartiteSpeciesPool}, 
    mass_action::MassActionRealization
)
    possible, energy = layer.data, mass_action.energy

    # get pairwise abundance combinations 
    combs = [x for x in combinations(collect(values(mass_action.abundance.data.dict)),2)]

    # combine pairwise abundance rates 
    pairwise_abundance_rates = broadcast_dims(+, [broadcast_dims(mass_action.realization_mode, c...) for c in combs]...)

    rate = @d energy .* possible .* pairwise_abundance_rates
    return rate
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
    layer::NetworkLayer{Potential}, 
    model::MassActionRealization
)
    rate = _get_rate_matrix(layer, model)
    realized = map(x-> x > 0 ? rand(Poisson(x)) : 0, rate)
    metadata = merge(layer.metadata, Dict(:realization_model => model))
    return NetworkLayer(Realized(), getspecies(layer), realized, metadata)
end

