"""
    Abundances{T<:AbstractSpeciesTrait}
"""
struct Abundances{T<:AbstractSpeciesTrait}
    data::T
end
Base.parent(a::Abundances) = parent(a.data)
Base.values(a::Abundances{<:PartitionedTrait}) = values(a.data)
Base.keys(a::Abundances{<:PartitionedTrait}) = keys(a.data)
Base.haskey(a::Abundances{<:PartitionedTrait}, k) = haskey(a.data, k)
Base.getindex(abd::Abundances, i) = abd.data[i]
