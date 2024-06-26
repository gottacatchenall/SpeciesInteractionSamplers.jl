"""
    struct RelativeAbundanceScaled <: DetectionModel

Model for generation detection probability where the probability of detecting an interaction between species `i` and species `j` is 
a product of the detection probabilities for each species, treated as independent of one-another. 

"""
@kwdef struct RelativeAbundanceScaled{T<:Real} <: DetectionModel
    scaling_param::T = 50.0
end

_detection_probability(species_ra, α) = 1 - (1 - species_ra)^α

Base.show(io::IO, ras::RelativeAbundanceScaled) = begin
    X = 0.0:0.01:1
    # The expected value of the RAs is 1/num_species,
    Y = map(x -> _detection_probability(x, ras.scaling_param), X)

    p = lineplot(log.(X), Y,
        xlabel="log(Relative Abundance)",
        ylabel="Detection Probability",
    )

    #pts = map(x -> _detection_probability(x, ras.scaling_param), ras.relabd.abundance)
    #scatterplot!(p, log.(ras.relabd.abundance), pts, marker=:xcross, color=:blue)
    print(io, p)
end


"""
    detectability(net::Network{Feasible,<:Global}, detection_model)

Returns a [`Detectable`](@ref) network representing the probability and [`Feasible`](@ref) interaction is successfully detected in presence of an observer.
"""
function detectability(
    detection_model::RelativeAbundanceScaled,
    net::Network{Feasible,<:Global},
    relabd::RA
) where {RA<:Abundance{RelativeAbundance}}

    α = detection_model.scaling_param
    ints = SpeciesInteractionNetworks.interactions(network(net))

    detect_probs = SpeciesInteractionNetworks.Quantitative(zeros(Float64, size(net)))

    detect_prob_net = SpeciesInteractionNetworks.SpeciesInteractionNetwork(network(net).nodes, detect_probs)
    for int in ints
        sᵢ, sⱼ, _ = int
        rᵢ, rⱼ = relabd[sᵢ], relabd[sⱼ]
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

    δ = adjacency(detection_prob)
    detected_count = zeros(Int, size(δ))
    function _detect(localnet)
        if !isnothing(localnet)
            ζ = adjacency(localnet)
            detected_count .= 0
            for idx in findall(!iszero, ζ)
                detected_count[idx] = rand(Binomial(ζ[idx], δ[idx]))
            end

            counts = Quantitative(detected_count)
            realized_net = SpeciesInteractionNetwork(localnet.nodes, counts)
            return realized_net
        end
    end

    _scale = map(_detect, net)

    if SC <: Global
        return Network{Detected}(net.species, _scale, network(_scale))
    else
        realized_meta_adj = sum(adjacency.(filter(!isnothing, _scale.network)))
        realized_meta_sin = SpeciesInteractionNetwork(net.metaweb.nodes, Binary(realized_meta_adj))
        return Network{Detected}(net.species, _scale, realized_meta_sin)
    end
end

