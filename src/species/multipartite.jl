
"""
    MultipartiteSpeciesPool

A container holding multiple biological partitions (e.g., plants, pollinators).

# Fields
- `partitions::Dict{Symbol, SpeciesPartition}`
"""
struct MultipartiteSpeciesPool <: AbstractSpeciesPool
    partitions::Dict{Symbol, SpeciesPartition}
end

MultipartiteSpeciesPool(; kwargs...) = MultipartiteSpeciesPool(Dict{Symbol, SpeciesPartition}())

function MultipartiteSpeciesPool(partitions::SpeciesPartition...; prefix=:partition)
    SpeciesPool(Dict([Symbol("$prefix$i")=>p for (i,p) in enumerate(partitions)]))
end

function MultipartiteSpeciesPool(partitions::Vector{<:SpeciesPartition}; kwargs...)
    SpeciesPool(partitions...; kwargs...)
end

function MultipartiteSpeciesPool(ns::Int...; partition_names = nothing, species_prefix = nothing, partition_prefix=:partition, kwargs...)
    partition_names = isnothing(partition_names) ? [Symbol("$partition_prefix$i") for i in eachindex(ns)] : partition_names
    MultipartiteSpeciesPool(Dict([partition_names[i]=>SpeciesPartition(n; prefix=Symbol(String(partition_names[i])*"_" ), kwargs...) for (i,n) in enumerate(ns)]))
end

function MultipartiteSpeciesPool(ns::Tuple; kwargs...)
    MultipartiteSpeciesPool(ns...; kwargs...)
end

function MultipartiteSpeciesPool(vecs::Vector{S}...; names=nothing, partition_prefix=:partition, kwargs...) where S<:Union{Symbol,String}
    partition_names = isnothing(names) ? [Symbol("$partition_prefix$i") for i in eachindex(vecs)] : names
    MultipartiteSpeciesPool(Dict([partition_names[i]=>SpeciesPartition(v; kwargs...) for (i,v) in enumerate(vecs)]))
end

"""
    add_partition!(pool::MultipartiteSpeciesPool, name::Symbol, partition::SpeciesPartition)

Add new species partition in the pool.
"""
function add_partition!(pool::MultipartiteSpeciesPool, name::Symbol, partition::SpeciesPartition)
    if haskey(pool.partitions, name)
        @warn "Overwriting existing partition :$name"
    end
    pool.partitions[name] = partition
    return pool
end
# Adding by raw list of names
function add_partition!(pool::MultipartiteSpeciesPool, name::Symbol, names::Vector{Symbol})
    add_partition!(pool, name, SpeciesPartition(names))
end

"""
    get_partition(pool::MultipartiteSpeciesPool, name::Symbol)

Retrieve a partition by name.
"""
function getpartition(pool::MultipartiteSpeciesPool, name::Symbol)
    if !haskey(pool.partitions, name)
        error("Partition :$name not found in MultipartiteSpeciesPool. Available: $(keys(pool.partitions))")
    end
    return pool.partitions[name]
end

"""
    getpartitions(pool::MultipartiteSpeciesPool)

Get all partitions
"""
function getpartitions(pool::MultipartiteSpeciesPool)
    return pool.partitions
end

"""
    getpartitionnames(pool::MultipartiteSpeciesPool)

Get all partition names
"""
function getpartitionnames(pool::MultipartiteSpeciesPool)
    return collect(keys(pool.partitions))
end

"""
    numpartitions(pool::MultipartiteSpeciesPool)

Get number of partitions in the SpeciesPool `pool`.
"""
function numpartitions(pool::MultipartiteSpeciesPool)
    length(getpartitions(pool))
end


# Base overloads
Base.getindex(pool::MultipartiteSpeciesPool, key::Symbol) = getpartition(pool, key)
Base.setindex!(pool::MultipartiteSpeciesPool, val::SpeciesPartition, key::Symbol) = add_partition!(pool, key, val)
Base.keys(pool::MultipartiteSpeciesPool) = keys(pool.partitions)
Base.values(pool::MultipartiteSpeciesPool) = values(pool.partitions)
Base.haskey(pool::MultipartiteSpeciesPool, key::Symbol) = haskey(pool.partitions, key)
Base.length(pool::MultipartiteSpeciesPool) = length(pool.partitions)
Base.iterate(pool::MultipartiteSpeciesPool, i=1) = iterate(pool.partitions, i)


"""
    numspecies(pool::MultipartiteSpeciesPool)
    numspecies(pool::MultipartiteSpeciesPool, name::Symbol)

Get the total number of species across all partitions, or within a specific partition.
"""
numspecies(pool::MultipartiteSpeciesPool, name::Symbol) = length(pool[name])
numspecies(pool::MultipartiteSpeciesPool) = sum(length(p) for p in values(pool.partitions))


"""
    getspecies(pool::MultipartiteSpeciesPool)

Return a dictionary mapping partition names to lists of species names.
"""
getspecies(pool::MultipartiteSpeciesPool) = Dict(k => v.names for (k, v) in pool.partitions)
getspecies(pool::MultipartiteSpeciesPool, name) = pool[name].names
getspeciesaxis(p::MultipartiteSpeciesPool) = NamedTuple{Tuple(keys(p.partitions))}(getspecies.(values(p.partitions)))



# Pretty printing
function Base.show(io::IO, pool::MultipartiteSpeciesPool)
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