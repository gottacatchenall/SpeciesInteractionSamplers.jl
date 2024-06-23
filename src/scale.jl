network(s::Scale) = s.network
adjacency(s::SpeciesInteractionNetwork) = s.edges.edges

struct Global{SIN<:SpeciesInteractionNetwork} <: Scale
    network::SIN
end
struct Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Matrix{Union{SIN,Nothing}}
end
Base.size(spat::Spatial) = size(network(spat))
Base.length(::Spatial) = 1
Base.eachindex(s::Spatial) = CartesianIndices(network(s))
Base.getindex(s::Spatial, ci::CartesianIndex) = network(s)[ci]
Base.getindex(s::Spatial, i::Integer) = network(s)[i]

struct Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Vector{Union{SIN,Nothing}}
end
Base.length(temp::Temporal) = length(network(temp))
Base.size(::Temporal) = (1, 1)
Base.eachindex(t::Temporal) = eachindex(network(t))
Base.getindex(t::Temporal, i::Integer) = network(t)[i]

struct Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Array{Union{SIN,Nothing},3}
end
Base.size(st::Spatiotemporal) = size(network(st))[1:2]
Base.length(st::Spatiotemporal) = size(network(st), 3)


