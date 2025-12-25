"""
    UnipartiteSpeciesPool
"""

struct UnipartiteSpeciesPool <: AbstractSpeciesPool
    species::SpeciesPartition
end
UnipartiteSpeciesPool(n::Int; kwargs...) = UnipartiteSpeciesPool(SpeciesPartition(n; kwargs...))

# Pass on methods to the single partition
Base.length(p::UnipartiteSpeciesPool) = length(p.species)
Base.eltype(p::UnipartiteSpeciesPool) = eltype(p.species)
Base.getindex(p::UnipartiteSpeciesPool, i) = getindex(p.species, i)
Base.iterate(p::UnipartiteSpeciesPool, state=1) = iterate(p.species, state)
Base.in(x::Symbol, p::UnipartiteSpeciesPool) = x in p.species

numspecies(p::UnipartiteSpeciesPool) = numspecies(p.species)
getspecies(p::UnipartiteSpeciesPool) = getspecies(p.species)
getspeciesaxis(p::UnipartiteSpeciesPool) = (species=getspecies(p),)
