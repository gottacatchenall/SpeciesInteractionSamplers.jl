
"""
    SpeciesPartition{S,T}

A concrete collection of species names and associated metadata/traits.

# Fields
- `names::Vector{S}`: The unique identifiers for species in this partition.
- `traits::T`: Optional container for traits
- `metadata::Dict{Symbol, Any}`: Additional metadata for the partition.
"""
struct SpeciesPartition{S,T} 
    names::Vector{S}
    traits::T
    metadata::Dict{Symbol, Any}
end

# Constructors  
function SpeciesPartition(names::Vector{S}; traits=missing, metadata=Dict{Symbol,Any}()) where {S<:Union{Symbol, String}}
    SpeciesPartition(names, traits, metadata)
end

function SpeciesPartition(n::Int; prefix=:s, traits=missing, metadata=Dict{Symbol,Any}())
    names = [Symbol("$prefix$i") for i in 1:n]
    SpeciesPartition(names, traits, metadata)
end


# Base methods for Partition
Base.length(p::SpeciesPartition) = length(p.names)
Base.eltype(::SpeciesPartition{S}) where S = S
Base.getindex(p::SpeciesPartition, i) = p.names[i]
Base.iterate(p::SpeciesPartition, state=1) = iterate(p.names, state)
Base.in(x::Symbol, p::SpeciesPartition) = x in p.names

getspecies(p::SpeciesPartition) = p.names
getspeciesaxis(p::SpeciesPartition, name) = NamedTuple{Tuple((name,))}((getspecies(p),))


numspecies(p::SpeciesPartition) = length(p)

# Pretty printing
function Base.show(io::IO, p::SpeciesPartition) 
    print(io, "SpeciesPartition with $(length(p)) species")
end

