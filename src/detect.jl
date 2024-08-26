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
    detectability(net::Metaweb{Feasible,<:Global}, detection_model)

Returns a [`Detectable`](@ref) network representing the probability and [`Feasible`](@ref) interaction is successfully detected in presence of an observer.
"""
function detectability(
    detection_model::RelativeAbundanceScaled,
    net::Metaweb{<:Global},
    relabd::RA
) where {RA<:Abundance{RelativeAbundance}}

    α = detection_model.scaling_param
    ints = SpeciesInteractionNetworks.interactions(networks(net))

    detect_probs = SpeciesInteractionNetworks.Quantitative(zeros(Float64, size(net)))

    detect_prob_net = SpeciesInteractionNetworks.SpeciesInteractionNetwork(networks(net).nodes, detect_probs)
    for int in ints
        sᵢ, sⱼ, _ = int
        rᵢ, rⱼ = relabd[sᵢ], relabd[sⱼ]
        # NOTE: theres no reason this can't be a joint distribution, w/o independence
        # assumption. But for now...
        δᵢⱼ = _detection_probability(rᵢ, α) * _detection_probability(rⱼ, α)
        detect_prob_net[sᵢ, sⱼ] = δᵢⱼ
    end
    return Metaweb(Detectable, net.species, Global(detect_prob_net), detect_prob_net)
end

"""
    detect(net::Metaweb{Realized,SC}, detection_prob::Metaweb{Detectable,<:Global})

Returns a detected network based on a [`Realized`](@ref) network and a [`Detectable`](@ref) network representing detection probabilities for each interaction.
"""
function detect!(
    mw::Metaweb{SC},
    detection_prob::Metaweb{<:Global}
) where {SC}
    δ = detection_prob.metaweb
    function _detect!(localnet)
        xs, ys, ζs = SparseArrays.findnz(adjacency(localnet))
        for idx in eachindex(xs)
            i,j, ζ = xs[idx], ys[idx], ζs[idx]
            localnet.edges.edges[i,j] = rand(Binomial(ζ, δ[i,j]))
        end 
    end
    
    mw.state = Detected

    map(_detect!, mw.scale.network[mw.scale.mask])
    mw 
end

