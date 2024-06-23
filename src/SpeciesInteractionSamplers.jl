module SpeciesInteractionSamplers

INTERACTION_REPL = true
_interactive_repl() = INTERACTION_REPL

_DEFAULT_SPECIES_RICHNESS = 30
_DEFAULT_NUM_TIMESTEPS = 100
_DEFAULT_SPATIAL_RESOLUTION = (50, 50)

using CairoMakie
using Distributions
using NeutralLandscapes
using LinearAlgebra
using Random
using SpeciesInteractionNetworks: Binary, Quantitative, Unipartite, SpeciesInteractionNetwork
using SpeciesInteractionNetworks: interactions, simplify, subgraph
using Term
using TestItems
using UnicodePlots

import SpeciesInteractionNetworks

export generate
export possible
export realizable
export realize
export detectability
export detect

export GenerationModel
export NetworkGenerator
export NicheModel, StochasticBlockModel
export AbundanceGenerator
export TrophicScaling, NormalizedLogNormal

export PhenologyGenerator
export UniformPhenology, PoissonPhenology

export RangeGenerator
export AutocorrelatedRange

export RealizationModel
export NeutrallyForbiddenLinks

export DetectionModel
export RelativeAbundanceScaled

export AbundanceTrait
export RelativeAbundance, Density, Count


export State
export Feasible, Possible, Realizable, Realized, Detectable, Detected

export Scale
export Global, Spatial, Temporal, Spatiotemporal

export SpeciesPool
export Network
export Range
export Phenology
export Occurrence

export occurrence


# Network utils
export mirror, aggregate
export species, numspecies

include("types.jl")
include("species.jl")
include("network.jl")
include("abundance.jl")
include("range.jl")
include("phenology.jl")
include("occupancy.jl")

include("map.jl")

include("possible.jl")
include("realizable.jl")
include("realize.jl")
include("detect.jl")

#= 
include(joinpath("networks", "metaweb.jl"))
include(joinpath("abundance", "relativeabundance.jl"))
include(joinpath("phenologies", "phenology.jl"))
include(joinpath("ranges", "range.jl"))
include(joinpath("ranges", "mosaic.jl"))

include(joinpath("networks", "utils.jl"))
include(joinpath("networks", "spatial.jl"))
include(joinpath("networks", "temporal.jl"))
include(joinpath("networks", "spatiotemporal.jl"))

include(joinpath("networks", "generators.jl"))
include(joinpath("abundance", "generators.jl"))
include(joinpath("phenologies", "generators.jl"))
include(joinpath("ranges", "generators.jl"))

include("realizable.jl") =#

end
