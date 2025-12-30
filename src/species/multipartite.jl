
"""
    BipartiteSpeciesPool

A container holding multiple biological partitions (e.g., plants, pollinators).

# Fields
- `partitions::Dict{Symbol, SpeciesPartition}`
"""
struct BipartiteSpeciesPool <: AbstractSpeciesPool
    partitions::Dict{Symbol, SpeciesPartition}
end

BipartiteSpeciesPool(; kwargs...) = BipartiteSpeciesPool(Dict{Symbol, SpeciesPartition}())

function BipartiteSpeciesPool(partitions::SpeciesPartition...; prefix=:partition)
    SpeciesPool(Dict([Symbol("$prefix$i")=>p for (i,p) in enumerate(partitions)]))
end

function BipartiteSpeciesPool(partitions::Vector{<:SpeciesPartition}; kwargs...)
    SpeciesPool(partitions...; kwargs...)
end

function BipartiteSpeciesPool(ns::Int...; partition_names = nothing, species_prefix = nothing, partition_prefix=:partition, kwargs...)
    partition_names = isnothing(partition_names) ? [Symbol("$partition_prefix$i") for i in eachindex(ns)] : partition_names
    BipartiteSpeciesPool(Dict([partition_names[i]=>SpeciesPartition(n; prefix=Symbol(String(partition_names[i])*"_" ), kwargs...) for (i,n) in enumerate(ns)]))
end

function BipartiteSpeciesPool(ns::Tuple; kwargs...)
    BipartiteSpeciesPool(ns...; kwargs...)
end

function BipartiteSpeciesPool(vecs::Vector{S}...; names=nothing, partition_prefix=:partition, kwargs...) where S<:Union{Symbol,String}
    partition_names = isnothing(names) ? [Symbol("$partition_prefix$i") for i in eachindex(vecs)] : names
    BipartiteSpeciesPool(Dict([partition_names[i]=>SpeciesPartition(v; kwargs...) for (i,v) in enumerate(vecs)]))
end

"""
    add_partition!(pool::BipartiteSpeciesPool, name::Symbol, partition::SpeciesPartition)

Add new species partition in the pool.
"""
function add_partition!(pool::BipartiteSpeciesPool, name::Symbol, partition::SpeciesPartition)
    if haskey(pool.partitions, name)
        @warn "Overwriting existing partition :$name"
    end
    pool.partitions[name] = partition
    return pool
end
# Adding by raw list of names
function add_partition!(pool::BipartiteSpeciesPool, name::Symbol, names::Vector{Symbol})
    add_partition!(pool, name, SpeciesPartition(names))
end

"""
    get_partition(pool::BipartiteSpeciesPool, name::Symbol)

Retrieve a partition by name.
"""
function getpartition(pool::BipartiteSpeciesPool, name::Symbol)
    if !haskey(pool.partitions, name)
        error("Partition :$name not found in BipartiteSpeciesPool. Available: $(keys(pool.partitions))")
    end
    return pool.partitions[name]
end

"""
    getpartitions(pool::BipartiteSpeciesPool)

Get all partitions
"""
function getpartitions(pool::BipartiteSpeciesPool)
    return pool.partitions
end

"""
    getpartitionnames(pool::BipartiteSpeciesPool)

Get all partition names
"""
function getpartitionnames(pool::BipartiteSpeciesPool)
    return collect(keys(pool.partitions))
end

"""
    numpartitions(pool::BipartiteSpeciesPool)

Get number of partitions in the SpeciesPool `pool`.
"""
function numpartitions(pool::BipartiteSpeciesPool)
    length(getpartitions(pool))
end


# Base overloads
Base.getindex(pool::BipartiteSpeciesPool, key::Symbol) = getpartition(pool, key)
Base.setindex!(pool::BipartiteSpeciesPool, val::SpeciesPartition, key::Symbol) = add_partition!(pool, key, val)
Base.keys(pool::BipartiteSpeciesPool) = keys(pool.partitions)
Base.values(pool::BipartiteSpeciesPool) = values(pool.partitions)
Base.haskey(pool::BipartiteSpeciesPool, key::Symbol) = haskey(pool.partitions, key)
Base.length(pool::BipartiteSpeciesPool) = length(pool.partitions)
Base.iterate(pool::BipartiteSpeciesPool, i=1) = iterate(pool.partitions, i)


"""
    numspecies(pool::BipartiteSpeciesPool)
    numspecies(pool::BipartiteSpeciesPool, name::Symbol)

Get the total number of species across all partitions, or within a specific partition.
"""
numspecies(pool::BipartiteSpeciesPool, name::Symbol) = length(pool[name])
numspecies(pool::BipartiteSpeciesPool) = sum(length(p) for p in values(pool.partitions))


"""
    getspecies(pool::BipartiteSpeciesPool)

Return a dictionary mapping partition names to lists of species names.
"""
getspecies(pool::BipartiteSpeciesPool) = Dict(k => v.names for (k, v) in pool.partitions)
getspecies(pool::BipartiteSpeciesPool, name) = pool[name].names
getspeciesaxis(p::BipartiteSpeciesPool) = NamedTuple{Tuple(keys(p.partitions))}(getspecies.(values(p.partitions)))



# Pretty printing
function Base.show(io::IO, pool::BipartiteSpeciesPool)
    n_partitions = length(pool)

    if n_partitions > 0
        total_spp = numspecies(pool)
        print(io, "SpeciesPool with $n_partitions $(n_partitions == 1 ? "partition" : "partitions") ($total_spp total species):\n")
        for (name, part) in pool.partitions
            print(io, "  :$(name) => $(length(part)) species\n")
        end
    else
        print(io, "Empty SpeciesPool")
    end
end