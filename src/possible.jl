function possible(args...)
    tprint("{red}{bold}ERROR:{/bold} The arguments to `possible` must be a `Feasible` network, and optionally `Occurrence` {red}data for each species.{/red}\n")
    throw(ArgumentError)
end

function _local_net(idx, net, occ)
    pres = present(occ, idx)
    localnet = subgraph(network(net), pres)

    if length(interactions(localnet)) > 0
        return localnet
    end
    return nothing
end

function possible(net::Network{Feasible,G}, occ::Occurrence{T}) where {G<:Global,T<:Union{Range,Phenology}}
    _scale = map(x -> _local_net(x, net, occ), occ)
    Network{Possible}(species(net), _scale)
end

possible(
    net::Network{Feasible,G},
    phenologies::Occurrence{P},
    ranges::Occurrence{R}
) where {G,R<:Range,P<:Phenology} = possible(net, ranges, phenologies)

function _spatiotemporal_local_net(x, t, adj, spnames, spat_pres, temp_pres)
    cooc_onehot = vec(spat_pres[x] .& temp_pres[t])
    if sum(cooc_onehot) > 0
        cooc_idx = findall(cooc_onehot)
        return SpeciesInteractionNetwork(
            Unipartite(spnames[cooc_idx]),
            Binary(adj[cooc_idx, cooc_idx])
        )
    end
    return nothing
end

function possible(
    net::Network{Feasible,G},
    ranges::Occurrence{R},
    phenologies::Occurrence{P}
) where {G<:Global,R<:Range,P<:Phenology}
    onehot(localspecies) = Bool.(sum(permutedims(localspecies) .== spnames, dims=2))

    adj = net.scale.network.edges.edges
    spnames = species(net).names

    spat_pres = [onehot(present(ranges, x)) for x in eachindex(ranges)]
    temp_pres = [onehot(present(phenologies, t)) for t in eachindex(phenologies)]

    _func = (x, t) -> _spatiotemporal_local_net(x, t, adj, spnames, spat_pres, temp_pres)
    st = map(_func, ranges, phenologies)

    Network{Possible}(
        species(net),
        st
    )
end



