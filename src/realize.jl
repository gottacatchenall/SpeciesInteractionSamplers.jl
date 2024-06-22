
function realize(net::Network{Realizable,SC}) where {SC}

    function _realize(localnet)
        if !isnothing(localnet)
            counts = SpeciesInteractionNetworks.Quantitative(zeros(Int, size(localnet)))
            realized_net = SpeciesInteractionNetworks.SpeciesInteractionNetwork(localnet.nodes, counts)
            for int in SpeciesInteractionNetworks.interactions(localnet)
                i, j, θ = int
                if θ > 0
                    realized_net[i, j] = rand(Poisson(θ))
                end
            end
            return realized_net
        end
    end

    _sc = SC.name.wrapper
    localnets = scale(net).network
    Network{Realized}(net.species, _sc(Union{SpeciesInteractionNetworks.SpeciesInteractionNetwork,Nothing}[_realize(localnet) for localnet in localnets]))
end
