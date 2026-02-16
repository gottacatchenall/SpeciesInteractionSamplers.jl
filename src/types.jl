"""
    GenerativeModel

Abstract type that is the supertype for any object passed to the [`generate`](@ref) method.
"""
abstract type GenerativeModel end 

"""
    NetworkGenerator

A supertype for all methods used to generate [`Feasible`](@ref) networks.

Currently, the concrete instances of `NetworkGenerator` are:

- [`NicheModel`](@ref)
- [`ErdosRenyi`](@ref)
"""
abstract type NetworkGenerator <: GenerativeModel end

"""
    PhenologyGenerator

A supertype for all methods used to generate [`Phenologies`](@ref)s. 

Currently, the concrete instances of PhenologyGenerator are:

- [`UniformPhenology`](@ref)
- [`PoissonPhenology`](@ref)
- [`GaussianMixturePhenology`](@ref)
"""
abstract type PhenologyGenerator <: GenerativeModel end

"""
    abstract type RangeGenerator end 

A supertype for all methods used to generate [`Ranges`](@ref)s. 

Currently, the concrete instances of `RangeGenerator` are:

- [`AutocorrelatedRange`](@ref)
"""
abstract type RangeGenerator <: GenerativeModel end


"""
    AbundanceGenerator

A supertype for all method used to generate [`Abundances`](@ref) distributions across a set of species in a [`AbstractSpeciesPool`](@ref)
"""
abstract type AbundanceGenerator <: GenerativeModel end


"""
    NetworkState

Network states representing stages in the sampling pipeline.
"""
abstract type NetworkState end

"""
    Feasible <: NetworkState


A network `Feasible` if it represents all interactions that are biologically capable of happening between pairs of species. 

Note that this does not mean that the interaction has ever been realized---for example, many interactions that are feasible may not have occurred in the present or past as the constituent species may never have co-occurred, but may become realizable in the future as species ranges and phenologies shift.
"""
struct Feasible <: NetworkState end

"""
    Potential <: NetworkState

A `Potential` network represents interactions between species that can both (a) feasibly interact and (b) co-occur at a given place/time. 
"""
struct Potential <: NetworkState end

"""
    Realized <: NetworkState

A `Realized` network describes a discrete number of actually realized interactions.
"""
struct Realized <: NetworkState end

"""
    Detected <: NetworkState

A `Detected` network represents the discrete number of detected interactions between each pair of species at each place/time.
"""
struct Detected <: NetworkState end

"""
    ProcessModel
"""
abstract type ProcessModel end


"""
    abstract type RealizationModel end

Supertype for all models that describe how a network goes from [`Potential`](@ref) to [`Realized`](@ref)
"""
abstract type RealizationModel <: ProcessModel end



"""
    abstract type DetectabilityModel end 

Supertype for all models that describe how likely each [`Feasible`](@ref) interaction is to be detected in the presence of an observer. 
"""
abstract type DetectabilityModel <: ProcessModel end

"""
    AbstractSpeciesPool
"""
abstract type AbstractSpeciesPool end 
