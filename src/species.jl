"""
    SpeciesPool{S}

A `SpeciesPool` represents a set of species, each identified with either a `Symbol` or `String` in a vector called `names`. Note that the order of species in `names` is assumed to be fixed, so the index of each species in `names` can be used an an integer identifier.
"""
@kwdef struct SpeciesPool{S<:Union{String,Symbol}}
    names::Vector{S} = [Symbol("s$i") for i in 1:_DEFAULT_SPECIES_RICHNESS]
end

Base.length(sp::SpeciesPool) = length(sp.names)
Base.getindex(sp::SpeciesPool, i) = sp.names[i]
Base.show(io::IO, sp::SP) where {SP<:SpeciesPool} = tprint(io, "$SP with $(numspecies(sp)) species")

"""
    numspecies(sp::SpeciesPool)

Returns the number of species in input [`SpeciesPool`](@ref) `sp`.
"""
numspecies(sp::SpeciesPool) = length(sp)
