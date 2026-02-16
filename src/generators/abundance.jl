function generate(
    gen::AbundanceGenerator,
    pool::UnipartiteSpeciesPool
)
    return Abundances(
        UnipartiteTrait(
            DimArray(
                generate(gen, numspecies(pool)), 
                getspeciesaxis(pool)
            )
        )
    )
end 

function generate(
    gen::AbundanceGenerator,
    pool::BipartiteSpeciesPool;
)
    abds = Dict{Symbol,DimArray}()
    for (partition_name, partition) in getpartitions(pool)
        abds[partition_name] = DimArray(generate(gen, numspecies(partition)), getspeciesaxis(partition, partition_name))
    end
    return Abundances(PartitionedTrait(abds))
end


# ====================================================================================
#
# Distribution-based 
#
# ====================================================================================

"""
    DistributionBasedAbundance <: AbundanceGenerator
"""
struct DistributionBasedAbundance <: AbundanceGenerator
    distribution::Distribution
end

LogNormalAbundance(; σ = 1.0) = DistributionBasedAbundance(Truncated(LogNormal(0, σ), 0, Inf))
PoissonAbundance(; λ = 10.0) = DistributionBasedAbundance(Truncated(Poisson(λ), 1, Inf))
NegativeBinomialAbundance(; μ = 10.0, concentration = 1.) = DistributionBasedAbundance(Truncated(NegativeBinomial(concentration,  concentration / (μ + concentration)), 1, Inf))
UniformAbundance() = DistributionBasedAbundance(Uniform(0,1))

function generate(
    gen::DistributionBasedAbundance, 
    num_species::Int
) 
    abundances = rand(gen.distribution, num_species)
    abundances = abundances ./ sum(abundances)
    return abundances
end


# ====================================================================================
#
# Power law 
#
# ====================================================================================

"""
    PowerLawAbundance <: AbundanceGenerator
"""
@kwdef struct PowerLawAbundance <: AbundanceGenerator
    exponent = 1.0
end

function generate(gen::PowerLawAbundance, num_species::Int)
    ranks = shuffle(1:num_species)
    abundances = ranks .^ (-gen.exponent)
    abundances ./= sum(abundances)
    return abundances
end

@testitem "DistributionBasedAbundance generators" begin
    # LogNormal
    gen = LogNormalAbundance()
    @test gen isa DistributionBasedAbundance
    abd = generate(gen, 10)
    @test length(abd) == 10
    @test sum(abd) ≈ 1.0

    # Poisson
    gen2 = PoissonAbundance()
    abd2 = generate(gen2, 8)
    @test length(abd2) == 8
    @test sum(abd2) ≈ 1.0

    # NegativeBinomial
    gen3 = NegativeBinomialAbundance()
    abd3 = generate(gen3, 6)
    @test length(abd3) == 6
    @test sum(abd3) ≈ 1.0

    # Custom LogNormal width
    gen4 = LogNormalAbundance(σ=2.0)
    abd4 = generate(gen4, 5)
    @test sum(abd4) ≈ 1.0
end

@testitem "PowerLawAbundance generator" begin
    gen = PowerLawAbundance(exponent=1.5)
    abd = generate(gen, 10)
    @test length(abd) == 10
    @test sum(abd) ≈ 1.0
    @test all(abd .> 0)

    # Default exponent
    gen2 = PowerLawAbundance()
    abd2 = generate(gen2, 5)
    @test sum(abd2) ≈ 1.0
end

@testitem "Abundance generation for Unipartite" begin
    import SpeciesInteractionSamplers as SIS

    pool = UnipartiteSpeciesPool(6)
    gen = LogNormalAbundance()
    abds = generate(gen, pool)

    @test abds isa Abundances
    @test abds.data isa SIS.UnipartiteTrait
    @test size(parent(abds), 1) == 6
    @test sum(parent(abds)) ≈ 1.0
end

@testitem "Abundance generation for Bipartite" begin
    import SpeciesInteractionSamplers as SIS

    pool = BipartiteSpeciesPool(4, 3; partition_names=[:plants, :pollinators])
    gen = PowerLawAbundance()
    abds = generate(gen, pool)

    @test abds isa Abundances
    @test abds.data isa SIS.PartitionedTrait
    @test haskey(abds, :plants)
    @test haskey(abds, :pollinators)
    @test size(abds[:plants], 1) == 4
    @test size(abds[:pollinators], 1) == 3

    # Each partition's abundances should sum to 1
    @test sum(abds[:plants]) ≈ 1.0
    @test sum(abds[:pollinators]) ≈ 1.0
end