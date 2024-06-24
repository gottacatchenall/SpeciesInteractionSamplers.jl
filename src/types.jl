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
    abstract type RangeGenerator end 

A supertype for all methods used to generate [`Range`](@ref)s. 

Currently, the concrete instances of `RangeGenerator` are:

- [`AutocorrelatedRange`](@ref)
"""
abstract type RangeGenerator <: GenerationModel end


"""
    abstract type State end

An supertype for all possible forms a [`Network`](@ref) can take. The set of subtypes for state are:

- [`Feasible`](@ref)
- [`Possible`](@ref)
- [`Realizable`](@ref)
- [`Realized`](@ref)
- [`Detectable`](@ref)
- [`Detected`](@ref)
"""
abstract type State end

"""
    abstract type Feasible <: State end

A [`Network`](@ref) is `Feasible` if it represents all interactions that are biologically capable of happening between pairs of species. 

Note that this does not mean that the interaction has ever been realized---for example, many interactions that are feasible may not have occurred in the present or past as the constituent species may never have co-occurred, but may become realizable in the future as species [`Range`](@ref)s and [`Phenology`](@ref)s change.
"""
abstract type Feasible <: State end

"""
    abstract type Possible <: State end

A `Possible` [`Network`](@ref) represents interactions between species that can both (a) feasibly interact and (b) co-occur at a given place/time. 
"""
abstract type Possible <: State end


"""
    abstract type Realizable <: State end

A `Realizable` network represents the possible interactions in a network, but is distinct from `Possible` networks because it contains the _rate of realization_ for each interaction.

Realizable networks are created using the [`realizable`](@ref) method called on a [`Possible`](@ref) [`Network`](@ref) and a [`RealizationModel`](@ref).
"""
abstract type Realizable <: State end

"""
    abstract type Realized <: State end

A `Realized` network describes a discrete number of actually realized interactions from a [`Realizable`](@ref) network.
"""
abstract type Realized <: State end

"""
    abstract type Detectable <: State end

A `Detectable` network represents the probability that any [`Feasible`](@ref) interaction will successfully be detected if it occurs in the presence of an observed.

`Detectable` networks are created using the [`detectable`](@ref) method called on a [`Feasible`](@ref) [`Network`](@ref) and a [`DetectionModel`](@ref)
"""
abstract type Detectable <: State end

"""
    abstract type Detected <: State end

A `Detected` network represents the discrete number of detected interactions between each pair of species at each place/time.

`Detected` networks are created using the [`detect`](@ref) method called on a [`Realized`](@ref) [`Network`](@ref) and a [`Detectable`](@ref) [`Network`](@ref)
"""
abstract type Detected <: State end

"""
    abstract type Scale end 

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
    abstract type RelativeAbundance end 

Reprsents species abundances as a vector `x` where each element represents the proportional species abundance. Note that `sum(x)` must equal `1`.
"""
abstract type RelativeAbundance <: AbundanceTrait end

abstract type Density <: AbundanceTrait end
abstract type Count <: AbundanceTrait end


"""
    abstract type RealizationModel end

Supertype for all models that describe how a [`Network`](@ref) goes from [`Possible`](@ref) to [`Realizable`](@ref)
"""
abstract type RealizationModel end

"""
    abstract type DetectionModel end 

Supertype for all models that describe how likely each [`Feasible`](@ref) interaction is to be detected in the presence of an observer. 
"""
abstract type DetectionModel end

