
function _compute_new_metaweb!(mw)
    adj = nothing
    if typeof(mw.scale) <: Global
        mw.metaweb.edges.edges .= adjacency(mw.scale)
    else
        _nets = mw.scale.network[mw.scale.mask]
        adj = sum([x.edges.edges for x in _nets])
        mw.metaweb.edges.edges .= adj
    end
end

@kwdef struct NeutrallyForbiddenLinks <: RealizationModel
    energy = 100.0 # TODO: refactor so energy can be a scalar/tensor that matches the scale of the network `realizable` is called on 
end

function _nfl_rate_matrix!(localnet, relabd_mat, energy)
    adj = adjacency(localnet)
    ra_sum = 0.0
    xs, ys = SparseArrays.findnz(adj)
    for idx in eachindex(xs)
        i,j = xs[idx], ys[idx]
        ra_sum += relabd_mat[i,j]
    end 
    for idx in eachindex(xs)
        i,j = xs[idx], ys[idx]
        localnet.edges.edges[i,j] = energy * (relabd_mat[i,j] / ra_sum)
    end 
end

function realizable!(
    nfl::NeutrallyForbiddenLinks,
    mw::M,
    relabd::RA
) where {M<:Metaweb,RA<:Abundance{RelativeAbundance}}
    relabd_mat = relabd.abundance .* relabd.abundance'
    unique_localities = prod(resolution(mw)) * length(mw)
    E = nfl.energy / unique_localities

    _net = typeof(mw.scale) <: Global ? [mw.scale.network] : mw.scale.network[mw.scale.mask]

    map(x -> _nfl_rate_matrix!(x, relabd_mat, E), _net)

    _compute_new_metaweb!(mw)
    mw.state = Realizable
    return mw
end

#=
struct Equal <: RealizationModel end


abstract type DirichletPrior end 

@kwdef struct IIDPseudocounts <: DirichletPrior
    distribution = Gamma(3,2)
end 
@kwdef struct DirichletPreference{T,P<:DirichletPrior}
    energy::T = 100
    prior::P = IIDPseudocounts()
end 
function _dirichlet_pref_matrix!(localnet, energy)
    
end 

function realizable!(
    pref::DirichletPreference,
    mw::M,
    relabd::RA
) where {M<:Metaweb,RA<:Abundance{RelativeAbundance}}
    unique_localities = prod(resolution(mw)) * length(mw)
    E = pref.energy / unique_localities
    
    map(x -> _dirichlet_pref_matrix!(x, E), mw.scale.network[mw.scale.mask])

    _compute_new_metaweb!(mw)
    mw.state = Realizable
    return mw
end
=#