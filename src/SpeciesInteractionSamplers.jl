module SpeciesInteractionSamplers

INTERACTIVE_REPL = true
_interactive_repl() = INTERACTIVE_REPL

_DEFAULT_SPECIES_RICHNESS = 30
_DEFAULT_NUM_TIMESTEPS = 100
_DEFAULT_SPATIAL_RESOLUTION = (50, 50)

using CairoMakie
using Distributions
using NeutralLandscapes
using LinearAlgebra
using Random
using SpeciesInteractionNetworks: SpeciesInteractionNetwork, interactions, Unipartite, Binary, Quantitative, subgraph, simplify
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

export Abundance
export AbundanceTrait
export RelativeAbundance, Density, Count

#export Binary, Probability

# Network utils
export mirror, aggregate
export scale
export species, richness, adjacency, numspecies

include("types.jl")
include("scale.jl")
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

end
