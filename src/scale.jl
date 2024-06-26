network(s::Scale) = s.network
adjacency(s::Scale) = adjacency.(network(s))
adjacency(s::SpeciesInteractionNetwork) = s.edges.edges

"""
    Global{SIN<:SpeciesInteractionNetwork} <: Scale

A `Global` [`Scale`](@ref) contains a single `SpeciesInteractionNetwork` that is aggregated across space and time, i.e. a metaweb. 
"""
struct Global{SIN<:SpeciesInteractionNetwork} <: Scale
    network::SIN
end
adjacency(s::Global) = adjacency(network(s))
resolution(s::Global) = (1, 1)
Base.length(::Global) = 1

"""
    Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Matrix{Union{SIN,Nothing}}
end
Base.size(s::Spatial) = size(network(s))
Base.length(::Spatial) = 1
Base.eachindex(s::Spatial) = CartesianIndices(network(s))
Base.getindex(s::Spatial, ci::CartesianIndex) = network(s)[ci]
Base.getindex(s::Spatial, i::Integer) = network(s)[i]
resolution(s::Spatial) = size(s.network)

"""
    Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Vector{Union{SIN,Nothing}}
end
Base.size(::Temporal) = (1, 1)
Base.length(t::Temporal) = length(network(t))
Base.eachindex(t::Temporal) = eachindex(network(t))
Base.getindex(t::Temporal, i::Integer) = network(t)[i]
resolution(::Temporal) = (1, 1)

"""
    Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Array{Union{SIN,Nothing},3}
end
Base.size(st::Spatiotemporal) = size(st.network[begin])
Base.length(st::Spatiotemporal) = size(network(st), 3)
resolution(st::Spatiotemporal) = size(st.network)[1:2]


