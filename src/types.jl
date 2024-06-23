"""
    abstract type GenerationModel

Abstract type that is the supertype for any object passed to the [`generate`](@ref) method.
"""
abstract type GenerationModel end

"""
    abstract type NetworkGenerator <: GenerationModel end 

A supertype for all methods used to generate [`Feasible`](@ref) [`Network`](@ref)s.

Currently, the concrete instances of `NetworkGenerator` are

- [`StochasticBlockModel`](@ref)
- [`NicheModel`](@ref)

"""
abstract type NetworkGenerator <: GenerationModel end

"""
    AbundanceGenerator

A supertype for all method used to generate [`Abundance`](@ref) distributions across a set of species in a [`SpeciesPool`](@ref)
"""
abstract type AbundanceGenerator <: GenerationModel end

"""
    PhenologyGenerator

A supertype for all methods used to generate [`Phenology`](@ref)s. 

Currently, the concrete instances of PhenologyGenerator are:

- [`UniformPhenology`](@ref)
- [`PoissonPhenology`](@ref)
"""
abstract type PhenologyGenerator <: GenerationModel end

"""
    RangeGenerator

A supertype for all methods used to generate [`Range`](@ref)s. 

Currently, the concrete instances of `RangeGenerator` are:

- [`AutocorrelatedRange`](@ref)
"""
abstract type RangeGenerator <: GenerationModel end


"""
    State

An supertype for all possible forms a [`Network`](@ref) can take. The set of subtypes for state are:

- [`Feasible`](@ref)
- [`Possible`](@ref)
- [`Realizable`](@ref)
- [`Realized`](@ref)
- [`Detectable`](@ref)
- [`Detected`](@ref)
"""
abstract type State end


abstract type Feasible <: State end
abstract type Possible <: State end
abstract type Realizable <: State end
abstract type Realized <: State end
abstract type Detectable <: State end
abstract type Detected <: State end

"""
    Scale

Abstract supertype for the different spatial/temporal scales at which a network can be described. 

Possible subtypes are:

- [`Global`](@ref)
- [`Spatial`](@ref)
- [`Temporal`](@ref)
- [`Spatiotemporal`](@ref) 

"""
abstract type Scale end

"""
    abstract type AbundanceTrait end 

Supertype for the different forms of ways species abundance can be represented, i.e.

- [`RelativeAbundance`](@ref)
- [`Density`](@ref)
- [`Count`](@ref)
"""

abstract type AbundanceTrait end

"""
    RelativeAbundance

Reprsents species abundances as a vector `x` where each element represents the proportional species abundance. Note that `sum(x)` must equal `1`.
"""
abstract type RelativeAbundance <: AbundanceTrait end

abstract type Density <: AbundanceTrait end
abstract type Count <: AbundanceTrait end


"""
    RealizationModel

Supertype for all models that describe how a [`Network`](@ref) goes from [`Possible`](@ref) to [`Realizable`](@ref)
"""
abstract type RealizationModel end

"""
    DetectionModel

Supertype for all models that describe how likely each [`Feasible`](@ref) interaction is to be detected in the presence of an observer. 
"""
abstract type DetectionModel end

