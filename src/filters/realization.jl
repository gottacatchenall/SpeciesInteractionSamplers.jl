
# =================================================================================
#
# MassActionRealization
#
# =================================================================================

"""
    MassActionRealization

    Realized interactions follow a Poisson process: ζᵢⱼ ~ Poisson(θᵢⱼ) where the rate θᵢⱼ is a function of
    the abundance of the species involved in the interaction.
"""
struct MassActionRealization{T,A,R} <: RealizationModel
    energy::T  # Can be scalar, or array matching dimensions
    abundance::A
    combination_mode::R
end

MassActionRealization(abundance; energy=1.0, combination_mode=AbundanceProduct()) = MassActionRealization(energy, abundance, combination_mode)

function Base.show(io::IO, model::MassActionRealization)
    print(io, "MassActionRealization(energy=$(model.energy), combination=$(typeof(model.combination_mode).name.name))")
end

# Unipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, UnipartiteSpeciesPool},
    mass_action::MassActionRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, mass_action.energy
    abundance = parent(mass_action.abundance)
    abundance2 = set(abundance, :species=>:species2)
    rate = @d possible .* broadcast_dims(mass_action.combination_mode, abundance, abundance2)
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=(1,2)), rate.dims)

    return normalized_rate
end

# Bipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, BipartiteSpeciesPool},
    mass_action::MassActionRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, mass_action.energy

    pairwise_abundance_rates = broadcast_dims(mass_action.combination_mode, collect(values(mass_action.abundance))...)
    rate = @d possible .* pairwise_abundance_rates

    # NOTE: this normalizes across all partitions. perhaps kwarg to do each partition separate?
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=1:numpartitions(layer.species)), rate.dims)
    return normalized_rate
end


# =================================================================================
#
# HomogeneousRealization
#
# =================================================================================

"""
    HomogeneousRealization

Realization model where all possible interactions are sampled from the same
distribution, regardless of species identity or abundance.

ζᵢⱼ ~ d for all (i,j) where the interaction is possible.
"""
struct HomogeneousRealization{D<:UnivariateDistribution} <: RealizationModel
    distribution::D
end

function Base.show(io::IO, model::HomogeneousRealization)
    print(io, "HomogeneousRealization($(model.distribution))")
end

function realize(
    layer::NetworkLayer{T},
    model::HomogeneousRealization
) where {T<:Union{Feasible,Potential}}
    possible = layer.data
    realized = map(x -> x > 0 ? rand(model.distribution) : 0, possible)
    metadata = merge(layer.metadata, Dict(:realization_model => model))
    return NetworkLayer(Realized(), getspecies(layer), realized, metadata)
end


# =================================================================================
#
# CustomRateRealization
#
# =================================================================================

"""
    CustomRateRealization

Realization model where each interaction has a user-specified rate, sampled from
a common distribution family.

ζᵢⱼ ~ D(rᵢⱼ) where D is a callable that maps a rate to a `Distribution`
and rᵢⱼ is the per-interaction rate. Defaults to `Poisson`.
"""
struct CustomRateRealization{R,D} <: RealizationModel
    rates::R
    distribution::D
end

CustomRateRealization(rates; distribution=Poisson) = CustomRateRealization(rates, distribution)

function Base.show(io::IO, model::CustomRateRealization)
    sz = size(model.rates)
    print(io, "CustomRateRealization($(sz[1])×$(sz[2]) rates)")
end

function realize(
    layer::NetworkLayer{T},
    model::CustomRateRealization
) where {T<:Union{Feasible,Potential}}
    possible = layer.data
    rates_data = model.rates isa DimArray ? parent(model.rates) : model.rates
    effective_rate = DimArray(Array(parent(possible)) .* rates_data, dims(possible))
    realized = map(x -> x > 0 ? rand(model.distribution(x)) : 0, effective_rate)
    metadata = merge(layer.metadata, Dict(:realization_model => model))
    return NetworkLayer(Realized(), getspecies(layer), realized, metadata)
end


# =================================================================================
#
# Generic realize()
#
# =================================================================================

"""
    realize(
        layer::NetworkLayer{<:Union{Feasible,Potential}},
        model::RealizationModel
    )

Transforms Feasible/Potential → Realized via stochastic process.

ζᵢⱼ ~ Poisson(θᵢⱼ) for locations/times where γᵢⱼ = true.
All `RealizationModel` subtypes share this logic; they differ only in `_get_rate_matrix`.
"""
function realize(
    layer::NetworkLayer{T},
    model::RealizationModel
) where {T<:Union{Feasible,Potential}}
    rate = _get_rate_matrix(layer, model)
    realized = map(x-> x > 0 ? rand(Poisson(x)) : 0, rate)
    metadata = merge(layer.metadata, Dict(:realization_model => model))
    return NetworkLayer(Realized(), getspecies(layer), realized, metadata)
end


# =================================================================================
#
# TraitMatchingRealization
#
# =================================================================================

"""
    TraitMatchingRealization

Realization model where interaction rate depends on the Euclidean distance
between species trait vectors, transformed by a kernel function.

Rate: θᵢⱼ = energy × kernel(‖traitᵢ - traitⱼ‖) × possible
"""
struct TraitMatchingRealization{T,TR,K<:TraitKernel} <: RealizationModel
    energy::T
    traits::TR
    kernel::K
end

TraitMatchingRealization(traits; energy=1.0, kernel=GaussianKernel(1.0)) =
    TraitMatchingRealization(energy, traits, kernel)

function Base.show(io::IO, model::TraitMatchingRealization)
    print(io, "TraitMatchingRealization(energy=$(model.energy), kernel=$(model.kernel))")
end

# Unipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, UnipartiteSpeciesPool},
    model::TraitMatchingRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, model.energy
    trait_matrix = Matrix(parent(model.traits))
    D = _pairwise_euclidean(trait_matrix, trait_matrix)
    affinity = model.kernel.(D)
    affinity_da = DimArray(affinity, dims(possible)[1:2])
    rate = @d possible .* affinity_da
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=(1,2)), rate.dims)
    return normalized_rate
end

# Bipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, BipartiteSpeciesPool},
    model::TraitMatchingRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, model.energy
    partition_names = collect(keys(model.traits))
    trait_matrices = [Matrix(model.traits[k]) for k in partition_names]
    D = _pairwise_euclidean(trait_matrices[1], trait_matrices[2])
    affinity = model.kernel.(D)
    interaction_dims = dims(possible)[1:length(partition_names)]
    affinity_da = DimArray(affinity, interaction_dims)
    rate = @d possible .* affinity_da
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=1:numpartitions(layer.species)), rate.dims)
    return normalized_rate
end


# =================================================================================
#
# TraitAbundanceRealization
#
# =================================================================================

"""
    TraitAbundanceRealization

Realization model combining mass-action abundance rates with trait-matching affinity.

Rate: θᵢⱼ = energy × f(abundanceᵢ, abundanceⱼ) × kernel(‖traitᵢ - traitⱼ‖) × possible
"""
struct TraitAbundanceRealization{T,A,TR,K<:TraitKernel,R} <: RealizationModel
    energy::T
    abundance::A
    traits::TR
    kernel::K
    combination_mode::R
end

TraitAbundanceRealization(abundance, traits; energy=1.0, kernel=GaussianKernel(1.0), combination_mode=AbundanceProduct()) =
    TraitAbundanceRealization(energy, abundance, traits, kernel, combination_mode)

function Base.show(io::IO, model::TraitAbundanceRealization)
    print(io, "TraitAbundanceRealization(energy=$(model.energy), kernel=$(model.kernel), combination=$(typeof(model.combination_mode).name.name))")
end

# Unipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, UnipartiteSpeciesPool},
    model::TraitAbundanceRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, model.energy

    # Abundance component
    abundance = parent(model.abundance)
    abundance2 = set(abundance, :species=>:species2)
    abundance_rates = broadcast_dims(model.combination_mode, abundance, abundance2)

    # Trait affinity component
    trait_matrix = Matrix(parent(model.traits))
    D = _pairwise_euclidean(trait_matrix, trait_matrix)
    affinity = model.kernel.(D)
    affinity_da = DimArray(affinity, dims(possible)[1:2])

    rate = @d possible .* abundance_rates .* affinity_da
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=(1,2)), rate.dims)
    return normalized_rate
end

# Bipartite
function _get_rate_matrix(
    layer::NetworkLayer{T, BipartiteSpeciesPool},
    model::TraitAbundanceRealization
) where {T<:Union{Feasible,Potential}}
    possible, energy = layer.data, model.energy

    # Abundance component
    pairwise_abundance_rates = broadcast_dims(model.combination_mode, collect(values(model.abundance))...)

    # Trait affinity component
    partition_names = collect(keys(model.traits))
    trait_matrices = [Matrix(model.traits[k]) for k in partition_names]
    D = _pairwise_euclidean(trait_matrices[1], trait_matrices[2])
    affinity = model.kernel.(D)
    interaction_dims = dims(possible)[1:length(partition_names)]
    affinity_da = DimArray(affinity, interaction_dims)

    rate = @d possible .* pairwise_abundance_rates .* affinity_da
    normalized_rate = @d energy .* DimArray(rate.data ./ mapslices(sum, rate.data, dims=1:numpartitions(layer.species)), rate.dims)
    return normalized_rate
end



# =================================================================================
#
# Tests
#
# =================================================================================

@testitem "MassActionRealization works with Unipartite" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)
    abundance = generate(LogNormalAbundance(), pool)

    model = MassActionRealization(abundance; energy=10.0)
    @test model.energy == 10.0

    realized = realize(layer, model)
    @test realized isa NetworkLayer{Realized}
    @test numspecies(realized) == 5
end

@testitem "MassActionRealization works with Bipartite" begin
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:prey, :predator])
    layer = generate(ErdosRenyi(0.5), pool)
    abundance = generate(LogNormalAbundance(), pool)

    model = MassActionRealization(abundance; energy=5.0)
    @test model.energy == 5.0

    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test realized.species isa BipartiteSpeciesPool
end

@testitem "MassActionRealization with different combination modes" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    abundance = generate(LogNormalAbundance(), pool)

    for mode in [AbundanceProduct(), AbundanceMean(), AbundanceMin(), AbundanceMax(), AbundanceGeometricMean()]
        model = MassActionRealization(abundance; energy=5.0, combination_mode=mode)
        @test model.combination_mode == mode 

        realized = realize(layer, model)
        @test realized isa NetworkLayer{Realized}
    end
end

@testitem "HomogeneousRealization works with Unipartite" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)

    model = HomogeneousRealization(Poisson(3.0))
    @test model.distribution == Poisson(3.0)

    realized = realize(layer, model)
    @test realized isa NetworkLayer{Realized}
    @test numspecies(realized) == 5
end

@testitem "HomogeneousRealization works with Bipartite" begin
    using Distributions
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:prey, :predator])
    layer = generate(ErdosRenyi(0.5), pool)

    model = HomogeneousRealization(Poisson(5.0))
    @test model.distribution == Poisson(5.0)
    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test realized.species isa BipartiteSpeciesPool
end

@testitem "HomogeneousRealization with different distributions" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)

    for dist in [Poisson(2.0), Poisson(10.0), Geometric(0.3)]
        model = HomogeneousRealization(dist)
        @test model.distribution == dist
        realized = realize(layer, model)
        @test realized isa NetworkLayer{Realized}
    end
end

@testitem "Pipeline with HomogeneousRealization" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)

    realized = layer |> HomogeneousRealization(Poisson(5.0))
    @test realized isa NetworkLayer{Realized}
end

@testitem "CustomRateRealization works with Unipartite" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)

    rates = rand(5, 5) .* 10
    model = CustomRateRealization(rates)

    realized = realize(layer, model)
    @test realized isa NetworkLayer{Realized}
    @test numspecies(realized) == 5
end

@testitem "CustomRateRealization works with Bipartite" begin
    using Distributions
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:prey, :predator])
    layer = generate(ErdosRenyi(0.5), pool)

    rates = rand(size(layer)...) .* 10
    model = CustomRateRealization(rates)
    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test realized.species isa BipartiteSpeciesPool
end

@testitem "CustomRateRealization with custom distribution" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)

    rates = rand(5, 5) .* 5
    model = CustomRateRealization(rates; distribution=λ -> Poisson(2λ))
    realized = realize(layer, model)
    @test realized isa NetworkLayer{Realized}
end

@testitem "Pipeline with CustomRateRealization" begin
    using Distributions
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)

    rates = rand(5, 5) .* 5
    realized = layer |> CustomRateRealization(rates)
    @test realized isa NetworkLayer{Realized}
end

@testitem "TraitMatchingRealization works with Unipartite Networks" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    trait_matrix = randn(5, 3)
    traits = InteractionTraits(trait_matrix, pool)

    model = TraitMatchingRealization(traits; energy=10.0)
    @test model.energy == 10.0

    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test numspecies(realized) == 5
end

@testitem "TraitMatchingRealization works with Bipartite Networks" begin
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:plants, :pollinators])
    layer = generate(ErdosRenyi(0.5), pool)
    matrices = Dict(:plants => randn(4, 2), :pollinators => randn(3, 2))
    traits = InteractionTraits(matrices, pool)

    model = TraitMatchingRealization(traits; energy=5.0)
    @test model.energy == 5.0

    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test realized.species isa BipartiteSpeciesPool
end

@testitem "TraitMatchingRealization with different kernels" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    traits = InteractionTraits(randn(5, 2), pool)

    for kernel in [GaussianKernel(0.5), GaussianKernel(2.0), ExponentialKernel(1.0), ExponentialKernel(3.0)]
        model = TraitMatchingRealization(traits; energy=10.0, kernel=kernel)
        @test model.kernel == kernel
        realized = realize(layer, model)
        @test realized isa NetworkLayer{Realized}
    end
end

@testitem "TraitAbundanceRealization works with Unipartite Networks" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    abundance = generate(LogNormalAbundance(), pool)
    traits = InteractionTraits(randn(5, 3), pool)

    model = TraitAbundanceRealization(abundance, traits; energy=10.0)
    @test model.energy == 10.0

    realized = realize(layer, model)
    @test realized isa NetworkLayer{Realized}
    @test numspecies(realized) == 5
end

@testitem "TraitAbundanceRealization works with Bipartite Networks" begin
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:plants, :pollinators])
    layer = generate(ErdosRenyi(0.5), pool)
    abundance = generate(LogNormalAbundance(), pool)
    matrices = Dict(:plants => randn(4, 2), :pollinators => randn(3, 2))
    traits = InteractionTraits(matrices, pool)
    model = TraitAbundanceRealization(abundance, traits; energy=5.0)
    @test model.energy == 5.0

    realized = realize(layer, model)

    @test realized isa NetworkLayer{Realized}
    @test realized.species isa BipartiteSpeciesPool
end

@testitem "TraitAbundanceRealization with different combination modes" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    abundance = generate(LogNormalAbundance(), pool)
    traits = InteractionTraits(randn(5, 2), pool)

    for mode in [AbundanceProduct(), AbundanceMean(), AbundanceMin()]
        model = TraitAbundanceRealization(abundance, traits; energy=5.0, combination_mode=mode)
        @test model.combination_mode == mode
        realized = realize(layer, model)
        @test realized isa NetworkLayer{Realized}
    end
end

@testitem "Pipeline with TraitMatchingRealization" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)
    traits = InteractionTraits(randn(5, 2), pool)

    realized = layer |> TraitMatchingRealization(traits; energy=10.0)
    @test realized isa NetworkLayer{Realized}
end

@testitem "Pipeline with TraitAbundanceRealization" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(0.5), pool)
    abundance = generate(LogNormalAbundance(), pool)
    traits = InteractionTraits(randn(5, 2), pool)

    realized = layer |> TraitAbundanceRealization(abundance, traits; energy=10.0)
    @test realized isa NetworkLayer{Realized}
end
