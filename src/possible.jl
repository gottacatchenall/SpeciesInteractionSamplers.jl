function possible(args...)
    tprint("{red}{bold}ERROR:{/bold} The arguments to `possible` must be a `Feasible` network, and optionally `Occurrence` {red}data for each species.{/red}\n")
    throw(ArgumentError)
end

function _local_net(idx, net, occ)
    meta_adj = adjacency(net)
    pres = present(occ, idx)

    local_adj = zeros(Bool, size(meta_adj))
    local_adj[pres, pres] .= meta_adj[pres, pres]
    if sum(local_adj) > 0
        return SpeciesInteractionNetwork(network(net).nodes, Binary(local_adj))
    end
    return nothing
end

function possible(
    net::Network{Feasible,G},
    occ::Occurrence{T}
) where {G<:Global,T<:Union{Range,Phenology}}
    _scale = map(x -> _local_net(x, net, occ), occ)
    possible_meta_adj = sum(adjacency.(filter(!isnothing, _scale.network)))
    possible_meta_sin = SpeciesInteractionNetwork(network(net).nodes, Binary(possible_meta_adj))
    Network{Possible}(species(net), _scale, possible_meta_sin)
end

function _spatiotemporal_local_net(x, t, meta_adj, nodes, spat_pres, temp_pres)
    cooc_onehot = vec(spat_pres[x] .& temp_pres[t])
    if sum(cooc_onehot) > 0
        pres = findall(cooc_onehot)

        local_adj = zeros(Bool, size(meta_adj))
        local_adj[pres, pres] .= meta_adj[pres, pres]

        return SpeciesInteractionNetwork(
            nodes,
            Binary(local_adj)
        )
    end
    return nothing
end

possible(
    net::Network{Feasible,G},
    phenologies::Occurrence{P},
    ranges::Occurrence{R}
) where {G,R<:Range,P<:Phenology} = possible(net, ranges, phenologies)

function possible(
    net::Network{Feasible,G},
    ranges::Occurrence{R},
    phenologies::Occurrence{P}
) where {G<:Global,R<:Range,P<:Phenology}
    sppool = species(net)
    spnames = sppool.names
    onehot(localspecies_idx) = begin
        x = zeros(Bool, length(spnames))
        x[localspecies_idx] .= 1
        return x
    end
    feasible_adj = adjacency(net)

    spat_pres = [onehot(present(ranges, x)) for x in eachindex(ranges)]
    temp_pres = [onehot(present(phenologies, t)) for t in eachindex(phenologies)]
    _func = (x, t) -> _spatiotemporal_local_net(x, t, feasible_adj, network(net).nodes, spat_pres, temp_pres)
    _scale = map(_func, ranges, phenologies)

    # TODO: condense these lines into a fcn, they are used here, above, and in realize.jl
    possible_meta_adj = sum(adjacency.(filter(!isnothing, _scale.network)))
    possible_meta_sin = SpeciesInteractionNetwork(network(net).nodes, Binary(possible_meta_adj))

    Network{Possible}(sppool, _scale, possible_meta_sin)
end


