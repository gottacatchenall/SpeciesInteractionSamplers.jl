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
    return Abundances(abundances)
end