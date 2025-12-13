
# Public API {#Public-API}

## Index {#Index}
- [`SpeciesInteractionSamplers.Abundance`](#SpeciesInteractionSamplers.Abundance)
- [`SpeciesInteractionSamplers.AbundanceGenerator`](#SpeciesInteractionSamplers.AbundanceGenerator)
- [`SpeciesInteractionSamplers.AutocorrelatedRange`](#SpeciesInteractionSamplers.AutocorrelatedRange)
- [`SpeciesInteractionSamplers.Detectable`](#SpeciesInteractionSamplers.Detectable)
- [`SpeciesInteractionSamplers.Detected`](#SpeciesInteractionSamplers.Detected)
- [`SpeciesInteractionSamplers.DetectionModel`](#SpeciesInteractionSamplers.DetectionModel)
- [`SpeciesInteractionSamplers.Feasible`](#SpeciesInteractionSamplers.Feasible)
- [`SpeciesInteractionSamplers.GenerationModel`](#SpeciesInteractionSamplers.GenerationModel)
- [`SpeciesInteractionSamplers.Global`](#SpeciesInteractionSamplers.Global)
- [`SpeciesInteractionSamplers.Metaweb`](#SpeciesInteractionSamplers.Metaweb)
- [`SpeciesInteractionSamplers.MetawebGenerator`](#SpeciesInteractionSamplers.MetawebGenerator)
- [`SpeciesInteractionSamplers.NicheModel`](#SpeciesInteractionSamplers.NicheModel)
- [`SpeciesInteractionSamplers.Phenology`](#SpeciesInteractionSamplers.Phenology)
- [`SpeciesInteractionSamplers.PhenologyGenerator`](#SpeciesInteractionSamplers.PhenologyGenerator)
- [`SpeciesInteractionSamplers.PoissonPhenology`](#SpeciesInteractionSamplers.PoissonPhenology)
- [`SpeciesInteractionSamplers.Possible`](#SpeciesInteractionSamplers.Possible)
- [`SpeciesInteractionSamplers.Range`](#SpeciesInteractionSamplers.Range)
- [`SpeciesInteractionSamplers.RangeGenerator`](#SpeciesInteractionSamplers.RangeGenerator)
- [`SpeciesInteractionSamplers.Realizable`](#SpeciesInteractionSamplers.Realizable)
- [`SpeciesInteractionSamplers.RealizationModel`](#SpeciesInteractionSamplers.RealizationModel)
- [`SpeciesInteractionSamplers.Realized`](#SpeciesInteractionSamplers.Realized)
- [`SpeciesInteractionSamplers.RelativeAbundance`](#SpeciesInteractionSamplers.RelativeAbundance)
- [`SpeciesInteractionSamplers.RelativeAbundanceScaled`](#SpeciesInteractionSamplers.RelativeAbundanceScaled)
- [`SpeciesInteractionSamplers.Scale`](#SpeciesInteractionSamplers.Scale)
- [`SpeciesInteractionSamplers.Spatial`](#SpeciesInteractionSamplers.Spatial)
- [`SpeciesInteractionSamplers.Spatiotemporal`](#SpeciesInteractionSamplers.Spatiotemporal)
- [`SpeciesInteractionSamplers.SpeciesPool`](#SpeciesInteractionSamplers.SpeciesPool)
- [`SpeciesInteractionSamplers.State`](#SpeciesInteractionSamplers.State)
- [`SpeciesInteractionSamplers.StochasticBlockModel`](#SpeciesInteractionSamplers.StochasticBlockModel-Tuple{})
- [`SpeciesInteractionSamplers.StochasticBlockModel`](#SpeciesInteractionSamplers.StochasticBlockModel)
- [`SpeciesInteractionSamplers.Temporal`](#SpeciesInteractionSamplers.Temporal)
- [`SpeciesInteractionSamplers.UniformPhenology`](#SpeciesInteractionSamplers.UniformPhenology)
- [`SpeciesInteractionSamplers.adjacency`](#SpeciesInteractionSamplers.adjacency-Tuple{Metaweb{<:Global}})
- [`SpeciesInteractionSamplers.detect!`](#SpeciesInteractionSamplers.detect!-Union{Tuple{SC},%20Tuple{Metaweb{SC},%20Metaweb{<:Global}}}%20where%20SC)
- [`SpeciesInteractionSamplers.detectability`](#SpeciesInteractionSamplers.detectability-Union{Tuple{RA},%20Tuple{RelativeAbundanceScaled,%20Metaweb{<:Global},%20RA}}%20where%20RA<:(Abundance{RelativeAbundance}))
- [`SpeciesInteractionSamplers.generate`](#SpeciesInteractionSamplers.generate-Union{Tuple{NicheModel{I,%20F}},%20Tuple{F},%20Tuple{I}}%20where%20{I,%20F})
- [`SpeciesInteractionSamplers.generate`](#SpeciesInteractionSamplers.generate-Tuple{StochasticBlockModel})
- [`SpeciesInteractionSamplers.generate`](#SpeciesInteractionSamplers.generate-Tuple{AutocorrelatedRange})
- [`SpeciesInteractionSamplers.mirror`](#SpeciesInteractionSamplers.mirror-Tuple{SpeciesInteractionNetworks.SpeciesInteractionNetwork})
- [`SpeciesInteractionSamplers.networks`](#SpeciesInteractionSamplers.networks-Tuple{Metaweb})
- [`SpeciesInteractionSamplers.numspecies`](#SpeciesInteractionSamplers.numspecies-Tuple{M}%20where%20M<:Metaweb)
- [`SpeciesInteractionSamplers.numspecies`](#SpeciesInteractionSamplers.numspecies-Tuple{SpeciesPool})
- [`SpeciesInteractionSamplers.occurrence`](#SpeciesInteractionSamplers.occurrence-Tuple{Range})
- [`SpeciesInteractionSamplers.possible`](#SpeciesInteractionSamplers.possible-Union{Tuple{P},%20Tuple{R},%20Tuple{G},%20Tuple{Metaweb{G},%20Occurrence{P},%20Occurrence{R}}}%20where%20{G,%20R<:Range,%20P<:Phenology})
- [`SpeciesInteractionSamplers.realizable!`](#SpeciesInteractionSamplers.realizable!-Union{Tuple{RA},%20Tuple{M},%20Tuple{NeutrallyForbiddenLinks,%20M,%20RA}}%20where%20{M<:Metaweb,%20RA<:(Abundance{RelativeAbundance})})
- [`SpeciesInteractionSamplers.richness`](#SpeciesInteractionSamplers.richness-Tuple{M}%20where%20M<:Metaweb)
- [`SpeciesInteractionSamplers.scale`](#SpeciesInteractionSamplers.scale-Tuple{Metaweb})
- [`SpeciesInteractionSamplers.species`](#SpeciesInteractionSamplers.species-Tuple{M}%20where%20M<:Metaweb)


## Documentation {#Documentation}
<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Abundance' href='#SpeciesInteractionSamplers.Abundance'><span class="jlbinding">SpeciesInteractionSamplers.Abundance</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Abundance{A<:AbundanceTrait,S,T}
```


A distribution of the abundance values of each species in a  [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool). 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/abundance.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.AbundanceGenerator' href='#SpeciesInteractionSamplers.AbundanceGenerator'><span class="jlbinding">SpeciesInteractionSamplers.AbundanceGenerator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AbundanceGenerator
```


A supertype for all method used to generate [`Abundance`](/reference/public#SpeciesInteractionSamplers.Abundance) distributions across a set of species in a [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L21-L25" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.AutocorrelatedRange' href='#SpeciesInteractionSamplers.AutocorrelatedRange'><span class="jlbinding">SpeciesInteractionSamplers.AutocorrelatedRange</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AutocorrelatedRange <: RangeGenerator
```


A [`RangeGenerator`](/reference/public#SpeciesInteractionSamplers.RangeGenerator) that uses NeutralLandscapes.jl&#39;s `DiamondSquare` landscape generator to create autocorrelated rasters with autocorrelatation parameter ranging between 0 and 1, where increasing values mean increasing autocorrelated. The autocorrelated raster is thresholded where all values in the raster above the `threshold` are present, and all values below are absent. The value of `threshold` is either provided as a scalar, or drawn from a distribution. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/range.jl#L35-L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Detectable' href='#SpeciesInteractionSamplers.Detectable'><span class="jlbinding">SpeciesInteractionSamplers.Detectable</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Detectable <: State end
```


A `Detectable` network represents the probability that any [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) interaction will successfully be detected if it occurs in the presence of an observed.

`Detectable` networks are created using the [`detectability`](/reference/public#SpeciesInteractionSamplers.detectability-Union{Tuple{RA},%20Tuple{RelativeAbundanceScaled,%20Metaweb{<:Global},%20RA}}%20where%20RA<:(Abundance{RelativeAbundance})) method called on a [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) and a [`DetectionModel`](/reference/public#SpeciesInteractionSamplers.DetectionModel)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L99-L105" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Detected' href='#SpeciesInteractionSamplers.Detected'><span class="jlbinding">SpeciesInteractionSamplers.Detected</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Detected <: State end
```


A `Detected` network represents the discrete number of detected interactions between each pair of species at each place/time.

`Detected` networks are created using the [`detect!`](/reference/public#SpeciesInteractionSamplers.detect!-Union{Tuple{SC},%20Tuple{Metaweb{SC},%20Metaweb{<:Global}}}%20where%20SC) method called on a [`Realized`](/reference/public#SpeciesInteractionSamplers.Realized) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) and a [`Detectable`](/reference/public#SpeciesInteractionSamplers.Detectable) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L108-L114" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.DetectionModel' href='#SpeciesInteractionSamplers.DetectionModel'><span class="jlbinding">SpeciesInteractionSamplers.DetectionModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type DetectionModel end
```


Supertype for all models that describe how likely each [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) interaction is to be detected in the presence of an observer. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L162-L166" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Feasible' href='#SpeciesInteractionSamplers.Feasible'><span class="jlbinding">SpeciesInteractionSamplers.Feasible</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Feasible <: State end
```


A [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) is `Feasible` if it represents all interactions that are biologically capable of happening between pairs of species. 

Note that this does not mean that the interaction has ever been realized–-for example, many interactions that are feasible may not have occurred in the present or past as the constituent species may never have co-occurred, but may become realizable in the future as species [`Range`](/reference/public#SpeciesInteractionSamplers.Range)s and [`Phenology`](/reference/public#SpeciesInteractionSamplers.Phenology)s change.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L66-L72" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.GenerationModel' href='#SpeciesInteractionSamplers.GenerationModel'><span class="jlbinding">SpeciesInteractionSamplers.GenerationModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type GenerationModel
```


Abstract type that is the supertype for any object passed to the [`generate`](/reference/public#SpeciesInteractionSamplers.generate-Tuple{AutocorrelatedRange}) method.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Global' href='#SpeciesInteractionSamplers.Global'><span class="jlbinding">SpeciesInteractionSamplers.Global</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Global{SIN<:SpeciesInteractionNetwork} <: Scale
```


A `Global` [`Scale`](/reference/public#SpeciesInteractionSamplers.Scale) contains a single `SpeciesInteractionNetwork` that is aggregated across space and time, i.e. a metaweb. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/scale.jl#L5-L9" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Metaweb' href='#SpeciesInteractionSamplers.Metaweb'><span class="jlbinding">SpeciesInteractionSamplers.Metaweb</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Metaweb{SC<:Scale,SP<:SpeciesPool}
```


A `Metaweb` represents a set of species and their interactions aggregated across space and/or time. 

A Metaweb is composed of a [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool) and a set of interactions defined at a given [`Scale`](/reference/public#SpeciesInteractionSamplers.Scale).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L1-L7" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.MetawebGenerator' href='#SpeciesInteractionSamplers.MetawebGenerator'><span class="jlbinding">SpeciesInteractionSamplers.MetawebGenerator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type MetawebGenerator <: GenerationModel end
```


A supertype for all methods used to generate [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb)s.

Currently, the concrete instances of `MetawebGenerator` are
- [`StochasticBlockModel`](/reference/public#SpeciesInteractionSamplers.StochasticBlockModel)
  
- [`NicheModel`](/reference/public#SpeciesInteractionSamplers.NicheModel)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L8-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.NicheModel' href='#SpeciesInteractionSamplers.NicheModel'><span class="jlbinding">SpeciesInteractionSamplers.NicheModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
NicheModel
```


A [`MetawebGenerator`](/reference/public#SpeciesInteractionSamplers.MetawebGenerator) that generates a food-web for a fixed number of `species` and an expected value of `connectance` (the proportion of possible edges that are feasible in the Metaweb). Proposed in @Williams2000SimRul.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L159-L163" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Phenology' href='#SpeciesInteractionSamplers.Phenology'><span class="jlbinding">SpeciesInteractionSamplers.Phenology</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Phenology
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/phenology.jl#L1-L3" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.PhenologyGenerator' href='#SpeciesInteractionSamplers.PhenologyGenerator'><span class="jlbinding">SpeciesInteractionSamplers.PhenologyGenerator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PhenologyGenerator
```


A supertype for all methods used to generate [`Phenology`](/reference/public#SpeciesInteractionSamplers.Phenology)s. 

Currently, the concrete instances of PhenologyGenerator are:
- [`UniformPhenology`](/reference/public#SpeciesInteractionSamplers.UniformPhenology)
  
- [`PoissonPhenology`](/reference/public#SpeciesInteractionSamplers.PoissonPhenology)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L28-L37" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.PoissonPhenology' href='#SpeciesInteractionSamplers.PoissonPhenology'><span class="jlbinding">SpeciesInteractionSamplers.PoissonPhenology</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
PoissonPhenology
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/phenology.jl#L60-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Possible' href='#SpeciesInteractionSamplers.Possible'><span class="jlbinding">SpeciesInteractionSamplers.Possible</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Possible <: State end
```


A `Possible` [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) represents interactions between species that can both (a) feasibly interact and (b) co-occur at a given place/time. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L75-L79" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Range' href='#SpeciesInteractionSamplers.Range'><span class="jlbinding">SpeciesInteractionSamplers.Range</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Range{T<:Number}
```


A `Range` represents the binary occurrence of species across space using a raster.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/range.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.RangeGenerator' href='#SpeciesInteractionSamplers.RangeGenerator'><span class="jlbinding">SpeciesInteractionSamplers.RangeGenerator</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type RangeGenerator end
```


A supertype for all methods used to generate [`Range`](/reference/public#SpeciesInteractionSamplers.Range)s. 

Currently, the concrete instances of `RangeGenerator` are:
- [`AutocorrelatedRange`](/reference/public#SpeciesInteractionSamplers.AutocorrelatedRange)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L40-L48" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Realizable' href='#SpeciesInteractionSamplers.Realizable'><span class="jlbinding">SpeciesInteractionSamplers.Realizable</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Realizable <: State end
```


A `Realizable` network represents the possible interactions in a network, but is distinct from `Possible` networks because it contains the _rate of realization_ for each interaction.

Realizable networks are created using the [`realizable!`](/reference/public#SpeciesInteractionSamplers.realizable!-Union{Tuple{RA},%20Tuple{M},%20Tuple{NeutrallyForbiddenLinks,%20M,%20RA}}%20where%20{M<:Metaweb,%20RA<:(Abundance{RelativeAbundance})}) method called on a [`Possible`](/reference/public#SpeciesInteractionSamplers.Possible) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) and a [`RealizationModel`](/reference/public#SpeciesInteractionSamplers.RealizationModel).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L83-L89" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.RealizationModel' href='#SpeciesInteractionSamplers.RealizationModel'><span class="jlbinding">SpeciesInteractionSamplers.RealizationModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type RealizationModel end
```


Supertype for all models that describe how a [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) goes from [`Possible`](/reference/public#SpeciesInteractionSamplers.Possible) to [`Realizable`](/reference/public#SpeciesInteractionSamplers.Realizable)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L155-L159" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Realized' href='#SpeciesInteractionSamplers.Realized'><span class="jlbinding">SpeciesInteractionSamplers.Realized</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Realized <: State end
```


A `Realized` network describes a discrete number of actually realized interactions from a [`Realizable`](/reference/public#SpeciesInteractionSamplers.Realizable) network.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L92-L96" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.RelativeAbundance' href='#SpeciesInteractionSamplers.RelativeAbundance'><span class="jlbinding">SpeciesInteractionSamplers.RelativeAbundance</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type RelativeAbundance end
```


Reprsents species abundances as a vector `x` where each element represents the proportional species abundance. Note that `sum(x)` must equal `1`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L144-L148" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.RelativeAbundanceScaled' href='#SpeciesInteractionSamplers.RelativeAbundanceScaled'><span class="jlbinding">SpeciesInteractionSamplers.RelativeAbundanceScaled</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
struct RelativeAbundanceScaled <: DetectionModel
```


Model for generation detection probability where the probability of detecting an interaction between species `i` and species `j` is  a product of the detection probabilities for each species, treated as independent of one-another. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/detect.jl#L1-L7" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Scale' href='#SpeciesInteractionSamplers.Scale'><span class="jlbinding">SpeciesInteractionSamplers.Scale</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type Scale end
```


Abstract supertype for the different spatial/temporal scales at which a network can be described. 

Possible subtypes are:
- [`Global`](/reference/public#SpeciesInteractionSamplers.Global)
  
- [`Spatial`](/reference/public#SpeciesInteractionSamplers.Spatial)
  
- [`Temporal`](/reference/public#SpeciesInteractionSamplers.Temporal)
  
- [`Spatiotemporal`](/reference/public#SpeciesInteractionSamplers.Spatiotemporal) 
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L117-L129" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Spatial' href='#SpeciesInteractionSamplers.Spatial'><span class="jlbinding">SpeciesInteractionSamplers.Spatial</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/scale.jl#L31-L33" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Spatiotemporal' href='#SpeciesInteractionSamplers.Spatiotemporal'><span class="jlbinding">SpeciesInteractionSamplers.Spatiotemporal</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/scale.jl#L45-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.SpeciesPool' href='#SpeciesInteractionSamplers.SpeciesPool'><span class="jlbinding">SpeciesInteractionSamplers.SpeciesPool</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
SpeciesPool{S}
```


A `SpeciesPool` represents a set of species, each identified with either a `Symbol` or `String` in a vector called `names`. Note that the order of species in `names` is assumed to be fixed, so the index of each species in `names` can be used an an integer identifier.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/species.jl#L1-L5" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.State' href='#SpeciesInteractionSamplers.State'><span class="jlbinding">SpeciesInteractionSamplers.State</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
abstract type State end
```


An supertype for all possible forms a [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) can take. The set of subtypes for state are:
- [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible)
  
- [`Possible`](/reference/public#SpeciesInteractionSamplers.Possible)
  
- [`Realizable`](/reference/public#SpeciesInteractionSamplers.Realizable)
  
- [`Realized`](/reference/public#SpeciesInteractionSamplers.Realized)
  
- [`Detectable`](/reference/public#SpeciesInteractionSamplers.Detectable)
  
- [`Detected`](/reference/public#SpeciesInteractionSamplers.Detected)
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/types.jl#L52-L63" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.StochasticBlockModel' href='#SpeciesInteractionSamplers.StochasticBlockModel'><span class="jlbinding">SpeciesInteractionSamplers.StochasticBlockModel</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
StochasticBlockModel <: MetawebGenerator
```


A [`MetawebGenerator`](/reference/public#SpeciesInteractionSamplers.MetawebGenerator) that generates a Metaweb based on assigning each node a group `node_ids`, and a matrix `mixing_matrix` which at each index `mixing_matrix[i,j]` describes the probability that an edge exists between a node in group `i` and a node in group `j`. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L187-L191" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.StochasticBlockModel-Tuple{}' href='#SpeciesInteractionSamplers.StochasticBlockModel-Tuple{}'><span class="jlbinding">SpeciesInteractionSamplers.StochasticBlockModel</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
StochasticBlockModel(; numspecies=SpeciesInteractionSamplers._DEFAULT_SPECIES_RICHNESS, numgroups=3)
```


Constructor for a [`StochasticBlockModel`](/reference/public#SpeciesInteractionSamplers.StochasticBlockModel) based on a set number of species and number of groups, where the mixing probabilities between groups `i` and `j` are drawn from `mixing_dist`


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L200-L204" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.Temporal' href='#SpeciesInteractionSamplers.Temporal'><span class="jlbinding">SpeciesInteractionSamplers.Temporal</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/scale.jl#L17-L19" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.UniformPhenology' href='#SpeciesInteractionSamplers.UniformPhenology'><span class="jlbinding">SpeciesInteractionSamplers.UniformPhenology</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
UniformPhenology
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/phenology.jl#L41-L43" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.adjacency-Tuple{Metaweb{<:Global}}' href='#SpeciesInteractionSamplers.adjacency-Tuple{Metaweb{<:Global}}'><span class="jlbinding">SpeciesInteractionSamplers.adjacency</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
adjacency(mw::Metaweb)
```


Returns the adjacency network(s) associated with a Metaweb `net`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L35-L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.detect!-Union{Tuple{SC}, Tuple{Metaweb{SC}, Metaweb{<:Global}}} where SC' href='#SpeciesInteractionSamplers.detect!-Union{Tuple{SC}, Tuple{Metaweb{SC}, Metaweb{<:Global}}} where SC'><span class="jlbinding">SpeciesInteractionSamplers.detect!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
detect(net::Metaweb{Realized,SC}, detection_prob::Metaweb{Detectable,<:Global})
```


Returns a detected network based on a [`Realized`](/reference/public#SpeciesInteractionSamplers.Realized) network and a [`Detectable`](/reference/public#SpeciesInteractionSamplers.Detectable) network representing detection probabilities for each interaction.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/detect.jl#L58-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.detectability-Union{Tuple{RA}, Tuple{RelativeAbundanceScaled, Metaweb{<:Global}, RA}} where RA<:Abundance{RelativeAbundance}' href='#SpeciesInteractionSamplers.detectability-Union{Tuple{RA}, Tuple{RelativeAbundanceScaled, Metaweb{<:Global}, RA}} where RA<:Abundance{RelativeAbundance}'><span class="jlbinding">SpeciesInteractionSamplers.detectability</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
detectability(net::Metaweb{Feasible,<:Global}, detection_model)
```


Returns a [`Detectable`](/reference/public#SpeciesInteractionSamplers.Detectable) network representing the probability and [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) interaction is successfully detected in presence of an observer.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/detect.jl#L30-L34" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.generate-Tuple{AutocorrelatedRange}' href='#SpeciesInteractionSamplers.generate-Tuple{AutocorrelatedRange}'><span class="jlbinding">SpeciesInteractionSamplers.generate</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generate(ar::AutocorrelatedRange)
```


Generates a [`Range`](/reference/public#SpeciesInteractionSamplers.Range) using the [`AutocorrelatedRange`](/reference/public#SpeciesInteractionSamplers.AutocorrelatedRange) [`RangeGenerator`](/reference/public#SpeciesInteractionSamplers.RangeGenerator).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/range.jl#L46-L50" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.generate-Tuple{StochasticBlockModel}' href='#SpeciesInteractionSamplers.generate-Tuple{StochasticBlockModel}'><span class="jlbinding">SpeciesInteractionSamplers.generate</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generate(sbm::StochasticBlockModel)
```


Method for generating a [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) using a [`StochasticBlockModel`](/reference/public#SpeciesInteractionSamplers.StochasticBlockModel) generator.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L211-L215" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.generate-Union{Tuple{NicheModel{I, F}}, Tuple{F}, Tuple{I}} where {I, F}' href='#SpeciesInteractionSamplers.generate-Union{Tuple{NicheModel{I, F}}, Tuple{F}, Tuple{I}} where {I, F}'><span class="jlbinding">SpeciesInteractionSamplers.generate</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generate(gen::NicheModel)
```


Generates a [`Feasible`](/reference/public#SpeciesInteractionSamplers.Feasible) [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) using the niche model for food-web generation from Williams-Martinez (2000).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L169-L173" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.mirror-Tuple{SpeciesInteractionNetworks.SpeciesInteractionNetwork}' href='#SpeciesInteractionSamplers.mirror-Tuple{SpeciesInteractionNetworks.SpeciesInteractionNetwork}'><span class="jlbinding">SpeciesInteractionSamplers.mirror</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
mirror(mw::SpeciesInteractionNetwork)
```


Returns a symmetric (i.e. undirected) version of the input `SpeciesInteractionNetwork` with no self loops (i.e. diagonal of the adjacency matrix is 0)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L243-L248" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.numspecies-Tuple{M} where M<:Metaweb' href='#SpeciesInteractionSamplers.numspecies-Tuple{M} where M<:Metaweb'><span class="jlbinding">SpeciesInteractionSamplers.numspecies</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
numspecies(mw::M) where {M<:Metaweb}
```


Returns the number of species in a [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) `mw`. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L64-L68" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.numspecies-Tuple{SpeciesPool}' href='#SpeciesInteractionSamplers.numspecies-Tuple{SpeciesPool}'><span class="jlbinding">SpeciesInteractionSamplers.numspecies</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
numspecies(sp::SpeciesPool)
```


Returns the number of species in input [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool) `sp`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/species.jl#L14-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.occurrence-Tuple{Range}' href='#SpeciesInteractionSamplers.occurrence-Tuple{Range}'><span class="jlbinding">SpeciesInteractionSamplers.occurrence</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
occurrence(r::Range)
```


Returns the occurrence raster associated with a [`Range`](/reference/public#SpeciesInteractionSamplers.Range)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/range.jl#L10-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.possible-Union{Tuple{P}, Tuple{R}, Tuple{G}, Tuple{Metaweb{G}, Occurrence{P}, Occurrence{R}}} where {G, R<:Range, P<:Phenology}' href='#SpeciesInteractionSamplers.possible-Union{Tuple{P}, Tuple{R}, Tuple{G}, Tuple{Metaweb{G}, Occurrence{P}, Occurrence{R}}} where {G, R<:Range, P<:Phenology}'><span class="jlbinding">SpeciesInteractionSamplers.possible</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
possible(net::Metaweb{G}, phenologies::Occurrence{P}, ranges::Occurrence{R})
```


Alternative method for `possible` with `Pheonology` and `Range` arguments flipped from the typical method.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/possible.jl#L51-L56" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.realizable!-Union{Tuple{RA}, Tuple{M}, Tuple{NeutrallyForbiddenLinks, M, RA}} where {M<:Metaweb, RA<:Abundance{RelativeAbundance}}' href='#SpeciesInteractionSamplers.realizable!-Union{Tuple{RA}, Tuple{M}, Tuple{NeutrallyForbiddenLinks, M, RA}} where {M<:Metaweb, RA<:Abundance{RelativeAbundance}}'><span class="jlbinding">SpeciesInteractionSamplers.realizable!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
realizable!
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/realizable.jl#L31-L33" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.richness-Tuple{M} where M<:Metaweb' href='#SpeciesInteractionSamplers.richness-Tuple{M} where M<:Metaweb'><span class="jlbinding">SpeciesInteractionSamplers.richness</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
richness(mw::M) where {M<:Metaweb}
```


Returns the number of species in the [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool) associated with the input [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) `mw`. 


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L50-L54" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.scale-Tuple{Metaweb}' href='#SpeciesInteractionSamplers.scale-Tuple{Metaweb}'><span class="jlbinding">SpeciesInteractionSamplers.scale</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
scale(mw::Metaweb)
```


Returns the input metaweb `mw` partitioned at the [`Scale`](/reference/public#SpeciesInteractionSamplers.Scale) it is defined at.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L28-L32" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SpeciesInteractionSamplers.species-Tuple{M} where M<:Metaweb' href='#SpeciesInteractionSamplers.species-Tuple{M} where M<:Metaweb'><span class="jlbinding">SpeciesInteractionSamplers.species</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
species(mw::M) where {M<:Metaweb}
```


Returns the [`SpeciesPool`](/reference/public#SpeciesInteractionSamplers.SpeciesPool) that belongs to the input [`Metaweb`](/reference/public#SpeciesInteractionSamplers.Metaweb) `mw`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/9f559e8e7379ce26111d9791a5994a0867379b1d/src/network.jl#L57-L61" target="_blank" rel="noreferrer">source</a></Badge>

</details>

