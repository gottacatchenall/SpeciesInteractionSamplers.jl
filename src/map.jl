"""
    Base.map(fcn, net::Network{ST,<:Global}) where {ST}

Overload of the `map` method for `Global` networks.
"""
function Base.map(fcn, net::Network{ST,<:Global}) where {ST}
    Global(fcn(network(net)))
end

function Base.map(fcn, net::Network{ST,SC}) where {ST,SC}
    _sc = SC.name.wrapper
    _sc(Union{SpeciesInteractionNetwork,Nothing}[fcn(localnet) for localnet in network(net)])
end

function Base.map(fcn, occ::Occurrence{T}) where {T}
    _sc = T <: Range ? Spatial : Temporal
    _sc(Union{SpeciesInteractionNetwork,Nothing}[fcn(x) for x in eachindex(occ)])
end

function Base.map(fcn, ranges::Occurrence{<:Range}, phen::Occurrence{<:Phenology}) where {T}
    return Spatiotemporal(Union{SpeciesInteractionNetwork,Nothing}[fcn(x, t) for x in eachindex(ranges), t in eachindex(phen)])
end
