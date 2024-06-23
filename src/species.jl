@kwdef struct SpeciesPool{S<:Union{String,Symbol}}
    names::Vector{S} = [Symbol("s$i") for i in 1:_DEFAULT_SPECIES_RICHNESS]
end

Base.length(sp::SpeciesPool) = length(sp.names)
Base.getindex(sp::SpeciesPool, i) = sp.names[i]
Base.show(io::IO, sp::SP) where {SP<:SpeciesPool} = tprint(io, "$SP with $(numspecies(sp)) species")
numspecies(sp::SpeciesPool) = length(sp)
