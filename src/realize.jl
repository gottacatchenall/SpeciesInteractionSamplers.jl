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
    Network{Realized}(
        net.species,
        _scale,
        net.metaweb
    )
end
