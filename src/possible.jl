function possible(args...)
    tprint("{red}{bold}ERROR:{/bold} The arguments to `possible` must be a `Feasible` network, and optionally `Occurrence` {red}data for each species.{/red}\n")
    throw(ArgumentError)
end

function _local_net(idx, net, occ)
    meta_adj = adjacency(net)
    pres = present(occ, idx)

    local_adj = zeros(Float64, size(meta_adj))
    # this is also slow
    local_adj[pres, pres] .= meta_adj[pres, pres]

    # TODO: this is slow
    if sum(local_adj) > 0
        return SpeciesInteractionNetwork(networks(net).nodes, Quantitative(local_adj))
    end
    return nothing
end

function possible(
    net::Metaweb{G},
    occ::Occurrence{T}
) where {G<:Global,T<:Union{Range,Phenology}}
    _scale = map(x -> _local_net(x, net, occ), occ)
    possible_meta_adj = sum(adjacency.(_scale.network[_scale.mask]))
    possible_meta_sin = SpeciesInteractionNetwork(networks(net).nodes, Quantitative(possible_meta_adj))
    Metaweb(Possible, species(net), _scale, possible_meta_sin)
end



function _spatiotemporal_local_net(x, t, local_adj, feasible_adj, nodes, spat_pres, temp_pres)
    cooc_onehot = vec(spat_pres[x] .& temp_pres[t])
    if sum(cooc_onehot) > 0
        pres = findall(cooc_onehot)

        local_adj .= 0

        local_adj[pres, pres] .= feasible_adj[pres, pres]
        if sum(local_adj) > 0
            return SpeciesInteractionNetwork(
                nodes,
                Quantitative(local_adj)
            )
        end
    end
    return nothing
end

"""
    possible(net::Metaweb{G}, phenologies::Occurrence{P}, ranges::Occurrence{R}) 

Alternative method for `possible` with `Pheonology` and `Range` arguments
flipped from the typical method.
"""
possible(net::Metaweb{G}, phenologies::Occurrence{P}, ranges::Occurrence{R}) where {G,R<:Range,P<:Phenology} = possible(net, ranges, phenologies)

function possible(
    net::Metaweb{G},
    ranges::Occurrence{R},  # store these ase sparse arrays to save allocs 
    phenologies::Occurrence{P}
) where {G<:Global,R<:Range,P<:Phenology}

    sppool = species(net)
    x = zeros(Bool, length(sppool))


    onehot(localspecies_idx) = begin
        x .= 0
        x[localspecies_idx] .= 1
        return x
    end
    
    feasible_adj = adjacency(net)

    spat_pres = [onehot(present(ranges, x)) for x in eachindex(ranges)]
    temp_pres = [onehot(present(phenologies, t)) for t in eachindex(phenologies)]

    local_adj = zeros(Float64, size(feasible_adj))


    _func = (x, t) -> _spatiotemporal_local_net(x, t, local_adj, feasible_adj, networks(net).nodes, spat_pres, temp_pres)
    _scale = map(_func, ranges, phenologies)
    


    # TODO: condense these lines into a fcn, they are used here, above, and in realize.jl
    #possible_meta_adj = sum(adjacency.(filter(!isnothing, _scale.network)))
    # possible_meta_sin = SpeciesInteractionNetwork(networks(net).nodes, Quantitative(possible_meta_adj))
    possible_meta_adj = sum(adjacency.(_scale.network[_scale.mask]))   
    possible_meta_sin = SpeciesInteractionNetwork(networks(net).nodes, Quantitative(possible_meta_adj))
    Metaweb(Possible, sppool, _scale, possible_meta_sin)
end


