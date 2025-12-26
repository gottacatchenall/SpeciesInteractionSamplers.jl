function generate(
    phenology_generator::PhenologyGenerator,
    pool::UnipartiteSpeciesPool,
    n_times::Int;
    kwargs...
)

    axis = merge(getspeciesaxis(pool), (time=1:n_times,))
    phens = [generate(phenology_generator, n_times; kwargs...) for i in 1:numspecies(pool)]
    Phenologies(
        UnipartiteTrait(
            DimArray(
                stack(phens, dims=1),
                axis
            )
        )
    )
end

function generate(
    phenology_generator::PhenologyGenerator,
    pool::MultipartiteSpeciesPool,
    n_times::Int;
    kwargs...
)
    phens = Dict{Symbol,DimArray}()
    for (partition_name, partition) in getpartitions(pool)
        axis = merge(getspeciesaxis(partition, partition_name), (time=1:n_times,))
        phens[partition_name] = DimArray(stack([generate(phenology_generator, n_times; kwargs...) for i in 1:numspecies(partition)], dims=1), axis)
    end
    return Phenologies(PartitionedTrait(phens))
end



# ====================================================================================
#
# Poisson 
#
# ====================================================================================

""" 
    PoissonPhenology
"""
struct PoissonPhenology <: PhenologyGenerator
    mean
end
  
"""
    generate(generator::PhenologyGenerator, n_species::Int, n_times::Int; kwargs...)

Generate species phenologies.
"""
function generate(gen::PoissonPhenology, n_times::Int; kwargs...)
    phenology = zeros(Bool, n_times)  # Placeholder
    len = rand(Poisson(gen.mean))
    starttime = rand(DiscreteUniform(1,n_times-len-1))
    phenology[starttime:starttime+len] .= 1
    return phenology
end


# ====================================================================================
#
# Uniform 
#
# ====================================================================================

"""
    UniformPhenology
"""
struct UniformPhenology <: PhenologyGenerator end

"""
    generate(generator::UniformPhenology, n_times::Int; kwargs...)

Generate species phenology patterns.
"""
function generate(gen::UniformPhenology, n_times::Int; kwargs...)
    starttime = rand(DiscreteUniform(1,n_times-1))
    endtime = rand(DiscreteUniform(starttime+1,n_times))
    phenology = zeros(Bool, n_times)
    phenology[starttime:endtime] .= 1
    return phenology
end


# ====================================================================================
#
# Gaussian Mixture 
#
# ====================================================================================

"""
    GaussianMixturePhenology
"""
@kwdef struct GaussianMixturePhenology <: PhenologyGenerator 
    mean_distribution = Uniform(0,1)
    std_distribution = Truncated(Normal(0,1), 0.1, Inf)
    num_components = 3
end

"""
    generate(generator::GaussianMixturePhenology, n_times::Int; kwargs...)

Generate species phenology patterns.
"""
function generate(gen::GaussianMixturePhenology, n_times::Int; kwargs...)
    μs = rand(gen.mean_distribution, gen.num_components)
    σs = rand(gen.std_distribution, gen.num_components)

    Xs = LinRange(0,1, n_times)
    raw_mixture = sum([[pdf(Normal(μs[i],σs[i]), x) for x in Xs] for i in eachindex(μs)])
    normalized_mixture = raw_mixture ./ maximum(raw_mixture)
    return normalized_mixture
end