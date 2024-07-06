function _realize(localnet)
    if !isnothing(localnet)
        adj = adjacency(localnet)
        ζ = map(θ -> θ > 0 ? rand(Poisson(θ)) : 0, adj)
        counts = Quantitative(ζ)
        realized_net = SpeciesInteractionNetwork(localnet.nodes, counts)
        return realized_net
    end
end


function realize(net::Network{Realizable,SC}) where {SC}
    _scale = map(_realize, net)

    mw_adj = SC <: Global ? adjacency(_scale.network) : sum(adjacency.(filter(!isnothing, _scale.network)))

    mw = SpeciesInteractionNetwork(
        net.metaweb.nodes,
        Binary(mw_adj)
    )


    Network{Realized}(
        net.species,
        _scale,
        mw
    )
end
