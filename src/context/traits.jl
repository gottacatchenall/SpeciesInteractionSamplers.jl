abstract type AbstractSpeciesTrait end 

struct UnipartiteTrait <: AbstractSpeciesTrait
    data::DimArray
end
numspecies(t::UnipartiteTrait) = size(t.data, 1)

struct PartitionedTrait{S} <: AbstractSpeciesTrait
    dict::Dict{S,<:DimArray}
end
numspecies(pt::PartitionedTrait) = sum(numspecies.(values(pt.dict)))
