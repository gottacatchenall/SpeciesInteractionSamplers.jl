module SpeciesInteractionSamplers
    using Combinatorics
    using Distributions
    using DimensionalData
    using NeutralLandscapes
    using StatsBase
    using Random
    using TestItems

    import SpeciesInteractionNetworks as SINs


    include("types.jl")

    include(joinpath("species", "partition.jl"))
    include(joinpath("species", "unipartite.jl"))
    include(joinpath("species", "multipartite.jl"))


    include(joinpath("context", "traits.jl"))
    include(joinpath("context", "ranges.jl"))
    include(joinpath("context", "phenologies.jl"))
    include(joinpath("context", "abundances.jl"))
    include(joinpath("context", "context.jl"))

    include("network.jl")


    include(joinpath("generators", "network.jl"))
    include(joinpath("generators", "range.jl"))
    include(joinpath("generators", "phenology.jl"))
    include(joinpath("generators", "abundance.jl"))

    include(joinpath("filters", "abundance_rates.jl"))
    include(joinpath("filters", "detection.jl"))
    include(joinpath("filters", "potential.jl"))
    include(joinpath("filters", "trait_kernels.jl"))
    include(joinpath("filters", "realization.jl"))

    include("pipeline.jl")

    # ============================================================================
    # Exports
    # ============================================================================
    export NetworkLayer, SpatiotemporalContext
    export Feasible, Potential, Realized, Detected
    export Ranges, Phenologies, Abundances
    export UnipartiteSpeciesPool, BipartiteSpeciesPool, SpeciesPartition
    export getpartition, getpartitions, getpartitionnames, add_partition!, numpartitions

    export AbundanceGenerator, LogNormalAbundance, PoissonAbundance, NegativeBinomialAbundance, DistributionBasedAbundance, PowerLawAbundance
    export NetworkGenerator, NicheModel, ConfigurationModel, ErdosRenyi
    export RangeGenerator, AutocorrelatedRange
    export PhenologyGenerator, PoissonPhenology, UniformPhenology, GaussianMixturePhenology
    export RealizationModel, MassActionRealization, NeutrallyForbiddenLinks, TraitMatchingRealization, TraitAbundanceRealization, HomogeneousRealization, CustomRateRealization
    export TraitKernel, GaussianKernel, ExponentialKernel
    export InteractionTraits
    export DetectabilityModel, BinomialDetection, AbundanceScaledDetection, PerfectDetection

    export AbstractDetectabilityRule, LinearDetectablity, ExponentialDetectability

    export AbundanceSum, AbundanceProduct, AbundanceGeometricMean, AbundanceMin, AbundanceMax, AbundanceMean, CustomAbundanceRule
    export DetectionCombinationMode, DetectabilitySum, DetectabilityProduct, DetectabilityMean, DetectabilityMin, DetectabilityMax, DetectabilityGeometricMean, CustomDetectabilityRule

    export generate, possibility, realize, detect, sample_network
    export interactions
    export numspecies, getspecies, getspeciesaxis


end
