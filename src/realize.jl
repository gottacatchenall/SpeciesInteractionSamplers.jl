function _realize(localnet)
    if !isnothing(localnet)
        counts = Quantitative(zeros(Int, size(localnet)))
        realized_net = SpeciesInteractionNetwork(localnet.nodes, counts)
        for int in interactions(localnet)
            i, j, θ = int
            if θ > 0
                realized_net[i, j] = rand(Poisson(θ))
            end
        end
        return realized_net
    end
end


function realize(net::Network{Realizable,SC}) where {SC}
    _scale = map(_realize, net)
    Network{Realized}(
        net.species,
        _scale,
    )
end
