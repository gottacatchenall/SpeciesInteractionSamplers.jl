"""
    Base.map(fcn, net::Metaweb{ST,<:Global}) where {ST}

Applies the function `fcn` to the [`Global`](@ref) [`Metaweb`](@ref) `net`. Overload of the `map` method for `Global` networks.
"""
function Base.map(fcn, net::Metaweb{<:Global}) 
    Global(fcn(networks(net)))
end

"""
    Base.map(fcn, net::Metaweb{ST,SC}) where {ST,SC}

foo
"""
function Base.map(fcn, net::Metaweb{SC}) where {SC<:Union{<:Spatial,<:Temporal,<:Spatiotemporal}}
    _sc = SC.name.wrapper

    localnets = Union{SpeciesInteractionNetwork,Nothing}[fcn(localnet) for localnet in networks(net)]

    xs, ys, θs = SparseArrays.findnz(adjacency(localnet))
    for idx in eachindex(xs)
        i,j, θ = xs[idx], ys[idx], θs[idx]
        localnet.edges.edges[i,j] = rand(Poisson(θ))
    end 
    mask = map(x->!isnothing(x), localnets) .== true

    _sc(localnets, mask)
end

function Base.map(fcn, occ::Occurrence{T})  where {T<:Union{Phenology,Range}}
    _sc = T <: Range ? Spatial : Temporal
    localnets = Union{SpeciesInteractionNetwork,Nothing}[fcn(x) for x in eachindex(occ)]
    
    mask = map(x->!isnothing(x), localnets) .== true
    _sc(localnets, mask)
end

function Base.map(fcn, ranges::Occurrence{<:Range}, phen::Occurrence{<:Phenology}) 
    localnets = Union{SpeciesInteractionNetwork,Nothing}[fcn(x, t) for x in eachindex(ranges), t in eachindex(phen)]
    mask = map(x->!isnothing(x), localnets) .== true

    return Spatiotemporal(localnets, mask)
end
