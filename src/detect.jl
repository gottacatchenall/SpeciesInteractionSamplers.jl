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

Base.show(io::IO, ras::RelativeAbundanceScaled) = begin
    X = 0.0:0.01:1
    Y = map(x -> _detection_probability(x, ras.scaling_param), X)

    p = lineplot(log.(X), Y,
        xlabel="log(Relative Abundance)",
        ylabel="Detection Probability",
    )

    pts = map(x -> _detection_probability(x, ras.scaling_param), ras.relabd.abundance)
    scatterplot!(p, log.(ras.relabd.abundance), pts, marker=:xcross, color=:blue)
    print(io, p)
end


"""
    detectability(net::Network{Feasible,<:Global}, detection_model)

Returns a [`Detectable`](@ref) network representing the probability and [`Feasible`](@ref) interaction is successfully detected in presence of an observer.
"""
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
    return Network{Detectable}(net.species, Global(detect_prob_net), detect_prob_net)
end

"""
    detect(net::Network{Realized,SC}, detection_prob::Network{Detectable,<:Global})

Returns a detected network based on a [`Realized`](@ref) network and a [`Detectable`](@ref) network representing detection probabilities for each interaction.
"""
function detect(
    net::Network{Realized,SC},
    detection_prob::Network{Detectable,<:Global}
) where {SC}

    function _detect(localnet)
        if !isnothing(localnet)
            detect_counts = Quantitative(zeros(Int, size(localnet)))
            detected_net = SpeciesInteractionNetwork(localnet.nodes, detect_counts)
            for int in interactions(localnet)
                i, j, C = int
                δᵢⱼ = network(detection_prob)[i, j]
                detected_net[i, j] = rand(Binomial(C, δᵢⱼ))
            end
            return detected_net
        end
    end

    _scale = map(_detect, net)

    if SC <: Global
        return Network{Detected}(net.species, _scale, network(_scale))
    else
        realized_meta_adj = sum(adjacency.(filter(!isnothing, _scale.network)))
        realized_meta_sin = SpeciesInteractionNetwork(network(net).nodes, Binary(realized_meta_adj))
        return Network{Detected}(net.species, _scale, realized_meta_sin)
    end
end

