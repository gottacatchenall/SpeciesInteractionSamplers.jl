abstract type AbstractSpeciesTrait end

struct UnipartiteTrait <: AbstractSpeciesTrait
    data::DimArray
end
numspecies(t::UnipartiteTrait) = size(t.data, 1)
Base.parent(t::UnipartiteTrait) = t.data

struct PartitionedTrait{S} <: AbstractSpeciesTrait
    dict::Dict{S,<:DimArray}
end
numspecies(pt::PartitionedTrait) = sum(size.(values(pt.dict), 1))
Base.parent(t::PartitionedTrait) = t.dict
Base.values(t::PartitionedTrait) = values(t.dict)
Base.keys(t::PartitionedTrait) = keys(t.dict)
Base.getindex(t::PartitionedTrait, k) = t.dict[k]
Base.haskey(t::PartitionedTrait, k) = haskey(t.dict, k)

"""
    InteractionTraits{T<:AbstractSpeciesTrait}

A wrapper holding species trait matrices used for trait-based realization models.
Each species has a trait vector, pairwise distances between trait vectors determine
interaction realization rate.
"""
struct InteractionTraits{T<:AbstractSpeciesTrait}
    data::T
end

Base.parent(it::InteractionTraits) = parent(it.data)
Base.values(it::InteractionTraits{<:PartitionedTrait}) = values(it.data)
Base.keys(it::InteractionTraits{<:PartitionedTrait}) = keys(it.data)
Base.getindex(it::InteractionTraits{<:PartitionedTrait}, k) = it.data[k]
Base.haskey(it::InteractionTraits{<:PartitionedTrait}, k) = haskey(it.data, k)

"""
    InteractionTraits(matrix::AbstractMatrix, pool::UnipartiteSpeciesPool)

Wrap a species×traits matrix for a unipartite pool. Rows correspond to species.
"""
function InteractionTraits(matrix::AbstractMatrix, pool::UnipartiteSpeciesPool)
    ax = getspeciesaxis(pool)
    trait_dim = Dim{:trait}(1:size(matrix, 2))
    da = DimArray(matrix, (Dim{:species}(ax.species), trait_dim))
    return InteractionTraits(UnipartiteTrait(da))
end

"""
    InteractionTraits(matrices::Dict{Symbol,<:AbstractMatrix}, pool::BipartiteSpeciesPool)

Wrap per-partition species×traits matrices for a bipartite pool.
"""
function InteractionTraits(matrices::Dict{Symbol,<:AbstractMatrix}, pool::BipartiteSpeciesPool)
    das = Dict{Symbol,DimArray}()
    for (name, mat) in matrices
        partition = getpartition(pool, name)
        sp_ax = getspeciesaxis(partition, name)
        trait_dim = Dim{:trait}(1:size(mat, 2))
        das[name] = DimArray(mat, (Dim{name}(sp_ax[name]), trait_dim))
    end
    return InteractionTraits(PartitionedTrait(das))
end

@testitem "InteractionTraits works with Unipartite" begin
    pool = UnipartiteSpeciesPool(5)
    mat = randn(5, 3)
    traits = InteractionTraits(mat, pool)
    @test traits isa InteractionTraits
end

@testitem "InteractionTraits works with Bipartite" begin
    import SpeciesInteractionSamplers as SIS

    pool = BipartiteSpeciesPool(4, 3; partition_names=[:plants, :pollinators])
    matrices = Dict(:plants => randn(4, 2), :pollinators => randn(3, 2))
    traits = InteractionTraits(matrices, pool)
    @test traits isa InteractionTraits
    @test traits.data isa SIS.PartitionedTrait
    @test haskey(traits, :plants)
    @test haskey(traits, :pollinators)
    @test size(traits[:plants], 1) == 4
    @test size(traits[:pollinators], 1) == 3
end

@testitem "UnipartiteTrait" begin
    import SpeciesInteractionSamplers as SIS

    pool = UnipartiteSpeciesPool(5)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    trait = ranges.data
    @test trait isa SIS.UnipartiteTrait
    @test numspecies(ranges) == 5
end

@testitem "PartitionedTrait" begin
    import SpeciesInteractionSamplers as SIS

    pool = BipartiteSpeciesPool(3, 2; partition_names=[:A, :B])
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    trait = ranges.data
    @test trait isa SIS.PartitionedTrait
    @test numspecies(ranges) == 5
    @test haskey(trait, :A)
    @test haskey(trait, :B)
end
