networks(s::Scale) = s.network
adjacency(s::Scale) = adjacency.(networks(s))
adjacency(s::SpeciesInteractionNetwork) = s.edges.edges

"""
    Global{SIN<:SpeciesInteractionNetwork} <: Scale

A `Global` [`Scale`](@ref) contains a single `SpeciesInteractionNetwork` that is aggregated across space and time, i.e. a metaweb. 
"""
struct Global{SIN<:SpeciesInteractionNetwork} <: Scale
    network::SIN
end
adjacency(s::Global) = adjacency(networks(s))
resolution(::Global) = (1, 1)
Base.length(::Global) = 1

"""
    Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Vector{Union{SIN,Nothing}}
    mask::BitArray{1}
end
Base.size(::Temporal) = (1, 1)
Base.length(t::Temporal) = length(networks(t))
Base.eachindex(t::Temporal) = eachindex(networks(t))
Base.getindex(t::Temporal, i::Integer) = networks(t)[i]
resolution(::Temporal) = (1, 1)


"""
    Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Array{Union{SIN,Nothing},2}
    mask::BitArray{2}
end
Base.size(s::Spatial) = size(networks(s))
Base.length(::Spatial) = 1
Base.eachindex(s::Spatial) = CartesianIndices(networks(s))
Base.getindex(s::Spatial, ci::CartesianIndex) = networks(s)[ci]
Base.getindex(s::Spatial, i::Integer) = networks(s)[i]
resolution(s::Spatial) = size(s.network)

"""
    Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
"""
struct Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Array{Union{SIN,Nothing},3}
    mask::BitArray{3}
end
Base.size(st::Spatiotemporal) = size(st.network[begin])
Base.length(st::Spatiotemporal) = size(networks(st), 3)
resolution(st::Spatiotemporal) = size(st.network)[1:2]


