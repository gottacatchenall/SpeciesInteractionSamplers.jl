"""
    NetworkLayer{T, S<:NetworkState, N}

A container for interaction data at a specific stage of the sampling pipeline.

# Fields
- `state::S`: Which stage of the pipeline this represents
- `species::SpeciesPool`: species pool for the interaction data
- `data::NamedArray{T,N}`: The interaction data with named dimensions
- `metadata::Dict{Symbol,Any}`: Arbitrary metadata 
"""
struct NetworkLayer{ST<:NetworkState,SP<:AbstractSpeciesPool,T,N}
    state::ST
    species::SP
    data::DimArray{T,N}
    metadata::Dict{Symbol,Any}
end

Base.size(layer::NetworkLayer) = size(layer.data)

getspecies(layer::NetworkLayer) = layer.species
numspecies(layer::NetworkLayer) = numspecies(getspecies(layer)) 

getnetworksize(layer::NetworkLayer{ST,<:MultipartiteSpeciesPool}) where ST = size(layer)[1:numpartitions(layer.species)]
getnetworksize(layer::NetworkLayer{ST,<:UnipartiteSpeciesPool}) where ST = size(layer)[1:2]


function Base.show(io::IO, layer::NetworkLayer{Feasible}) 
    print(io, "Feasible network with $(numspecies(layer)) species and $(sum(layer.data)) interactions")
end 

function Base.show(io::IO, layer::NetworkLayer{S}) where {S} 
    print(io, "$S network with $(numspecies(layer)) species and $(sum(layer.data)) total interactions")
end 