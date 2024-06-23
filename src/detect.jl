"""
    struct RelativeAbundanceScaled <: DetectionModel

Model for generation detection probability where the probability of detecting an interaction between species `i` and species `j` is 
a product of the detection probabilities for each species, treated as independent of one-another. 

"""
struct RelativeAbundanceScaled <: DetectionModel
    relabd::Abundance{RelativeAbundance}
    scaling_param
end

_detection_probability(species_ra, α) = 1 - (1 - species_ra)^α

function detectability(
    net::Network{Feasible,<:Global},
    detection_model::RelativeAbundanceScaled
)

    ra = detection_model.relabd
    α = detection_model.scaling_param
    ints = SpeciesInteractionNetworks.interactions(network(net))

    detect_probs = SpeciesInteractionNetworks.Quantitative(zeros(Float64, size(net)))

    detect_prob_net = SpeciesInteractionNetworks.SpeciesInteractionNetwork(network(net).nodes, detect_probs)
    for int in ints
        sᵢ, sⱼ, _ = int
        rᵢ, rⱼ = ra[sᵢ], ra[sⱼ]
        # NOTE: theres no reason this can't be a joint distribution, w/o independence
        # assumption. But for now...
        δᵢⱼ = _detection_probability(rᵢ, α) * _detection_probability(rⱼ, α)
        detect_prob_net[sᵢ, sⱼ] = δᵢⱼ
    end
    return Network{Detectable}(net.species, Global(detect_prob_net))
end


function detect(
    net::Network{Realized,SC},
    detection_prob::Network{Detectable,<:Global}
) where {SC}


    function _detect(localnet)
        if !isnothing(localnet)
            detect_counts = SpeciesInteractionNetworks.Quantitative(zeros(Int, size(localnet)))
            detected_net = SpeciesInteractionNetworks.SpeciesInteractionNetwork(localnet.nodes, detect_counts)
            for int in SpeciesInteractionNetworks.interactions(localnet)
                i, j, C = int
                δᵢⱼ = network(detection_prob)[i, j]
                detected_net[i, j] = rand(Binomial(C, δᵢⱼ))
            end
            return detected_net
        end
    end

    _sc = SC.name.wrapper
    localnets = network(net)
    Network{Detected}(net.species, _sc([_detect(localnet) for localnet in localnets]))
end
