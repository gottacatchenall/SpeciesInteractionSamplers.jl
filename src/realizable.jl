
struct NeutrallyForbiddenLinks <: RealizationModel
    relative_abundance::Abundance{RelativeAbundance}
end
struct Equal <: RealizationModel end

function realizable(
    net::Network{ST,SC},
    rm::NeutrallyForbiddenLinks
) where {ST<:Union{Feasible,Possible},SC}
    relabd = rm.relative_abundance

    function _rate_matrix(localnet)
        if !isnothing(localnet)
            rates = SpeciesInteractionNetworks.Quantitative(zeros(Float32, size(localnet)))
            rate_network = SpeciesInteractionNetworks.SpeciesInteractionNetwork(localnet.nodes, rates)
            ra_sum = 0.0
            ints = SpeciesInteractionNetworks.interactions(localnet)
            for int in ints
                spᵢ, spⱼ, θᵢⱼ = int
                rᵢ, rⱼ = relabd[spᵢ], relabd[spⱼ]
                θᵢⱼ = rᵢ * rⱼ
                rate_network[spᵢ, spⱼ] = θᵢⱼ
                ra_sum += θᵢⱼ
            end
            return rate_network ./ ra_sum
        end
    end

    _sc = SC.name.wrapper
    localnets = scale(net).network
    Network{Realizable}(net.species, _sc(Union{SpeciesInteractionNetworks.SpeciesInteractionNetwork,Nothing}[_rate_matrix(localnet) for localnet in localnets]))
end
