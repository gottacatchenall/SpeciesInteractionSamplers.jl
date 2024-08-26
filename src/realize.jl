function _realize!(localnet)
    xs, ys, θs = SparseArrays.findnz(adjacency(localnet))
    for idx in eachindex(xs)
        i,j, θ = xs[idx], ys[idx], θs[idx]
        localnet.edges.edges[i,j] = rand(Poisson(θ))
    end 
end


function realize!(mw::Metaweb{SC}) where {SC}

    # this is used everywhere, should be a fcn
    _net = SC <: Global ? [mw.scale.network] : mw.scale.network[mw.scale.mask] 
    map(_realize!, _net)

    mw_adj = SC <: Global ? adjacency(mw.scale.network) : sum(adjacency.(filter(!isnothing, mw.scale.network)))
   
    mw.state = Realized
    mw.metaweb = SpeciesInteractionNetwork(
        mw.metaweb.nodes,
        Quantitative(mw_adj)
    )

    mw
end
