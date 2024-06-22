function possible(::Network{ST,SC}, args...) where {ST,SC}
    tprint("{red}Possible must be called on a {bold}Feasible{/bold} network{/red}\n")
    throw(ArgumentError)
end

function possible(net::Network{Feasible,G}, occ::Occurrence{T}) where {G<:Global,T<:Union{Range,Phenology}}
    #nets = [Base.copy(network(net)) for _ in eachindex(occ)]

    # TODO refactor so all empty networks a dropped and replaced in the nets datastructure 
    function _get_local_net(idx)
        pres = present(occ, idx)
        localnet = Base.copy(network(net))
        localnet = SpeciesInteractionNetworks.subgraph(localnet, pres)

        if length(SpeciesInteractionNetworks.interactions(localnet)) > 0
            return localnet
        end
        return nothing
    end
    nets = Union{SpeciesInteractionNetworks.SpeciesInteractionNetwork,Nothing}[_get_local_net(x) for x in eachindex(occ)]

    SC = T <: Range ? Spatial : Temporal
    Network{Possible}(species(net), SC(nets))
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
    spnames = species(net).names

    adj = net.scale.network.edges.edges

    onehot(localspecies) = Bool.(sum(permutedims(localspecies) .== spnames, dims=2))
    findidx(sp) = findfirst(isequal(sp), spnames)

    spat_pres = [onehot(present(ranges, x)) for x in eachindex(ranges)]
    temp_pres = [onehot(present(phenologies, t)) for t in eachindex(phenologies)]


    function local_net(x, t)
        cooc_onehot = vec(spat_pres[x] .& temp_pres[t])

        if sum(cooc_onehot) > 0

            cooc_idx = findall(cooc_onehot)
            return SpeciesInteractionNetwork(
                SpeciesInteractionNetworks.Unipartite(spnames[cooc_idx]),
                SpeciesInteractionNetworks.Binary(adj[cooc_idx, cooc_idx])
            )
        end
        return nothing
    end

    ST = Spatiotemporal(Union{SpeciesInteractionNetworks.SpeciesInteractionNetwork,Nothing}[local_net(x, t) for x in eachindex(ranges), t in eachindex(phenologies)])

    Network{Possible}(
        species(net),
        ST
    )
end



