struct NeutrallyForbiddenLinks <: RealizationModel
    relative_abundance::Abundance{RelativeAbundance}
    energy # TODO: refactor so energy is a scalar/tensor that matches the scale of the network `realizable` is called on 
end
struct Equal <: RealizationModel end

function _rate_matrix(localnet, relabd, energy)
    if !isnothing(localnet)
        rates = Quantitative(zeros(Float32, size(localnet)))
        rate_network = SpeciesInteractionNetwork(localnet.nodes, rates)
        ra_sum = 0.0
        ints = interactions(localnet)
        for int in ints
            spᵢ, spⱼ, θᵢⱼ = int
            rᵢ, rⱼ = relabd[spᵢ], relabd[spⱼ]
            θᵢⱼ = rᵢ * rⱼ
            rate_network[spᵢ, spⱼ] = θᵢⱼ
            ra_sum += θᵢⱼ
        end
        return (energy .* rate_network) ./ ra_sum
    end
end


function realizable(
    net::Network{ST,SC},
    rm::NeutrallyForbiddenLinks
) where {ST<:Union{Feasible,Possible},SC}
    relabd, energy = rm.relative_abundance, rm.energy

    _scale = map(x -> _rate_matrix(x, relabd, energy), net)
    Network{Realizable}(
        net.species,
        _scale,
    )
end
