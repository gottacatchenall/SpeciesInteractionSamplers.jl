@kwdef struct NeutrallyForbiddenLinks <: RealizationModel
    energy = 100.0 # TODO: refactor so energy can be a scalar/tensor that matches the scale of the network `realizable` is called on 
end
struct Equal <: RealizationModel end

function _rate_matrix(localnet, θ, relabd_mat, energy)
    if !isnothing(localnet)
        θ .= 0
        ra_sum = 0.0
        adj = adjacency(localnet)
        if sum(adj) > 0
            for idx in findall(adj)
                θ[idx] = relabd_mat[idx]
                ra_sum += θ[idx]
            end
            return SpeciesInteractionNetwork(
                localnet.nodes,
                Quantitative(energy .* (θ ./ ra_sum))
            )
        end
    end
end

function realizable(
    nfl::NeutrallyForbiddenLinks,
    net::N,
    relabd::RA
) where {N<:Union{Network{<:Feasible},Network{<:Possible}},RA<:Abundance{RelativeAbundance}}
    relabd_mat = relabd.abundance .* relabd.abundance'
    θ = zeros(Float32, size(net))

    # TODO: figure out how to deal wiht variance in energy

    unique_localities = prod(resolution(net)) * length(net)

    E = nfl.energy / unique_localities
    _scale = map(x -> _rate_matrix(x, θ, relabd_mat, E), net)

    adj = nothing
    if typeof(_scale) <: Global 
        adj = adjacency(_scale) 
    else 
        adj = sum(adjacency.(filter(x->!isnothing(x), _scale.network)))
    end 
    
    mw = SpeciesInteractionNetwork(net.metaweb.nodes, Binary(adj))


    Network{Realizable}(
        net.species,
        _scale,
        mw
    )
end
