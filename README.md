# SpeciesInteractionSamplers.jl

`SpeciesInteractionSamplers.jl` is a Julia package for simulating the process of
sampling species interaction networks with spatiotemporal variation in species
occurrence. It is built on `SpeciesInteractionNetworks.jl`, and uses
`NeutralLandscapes.jl` and `Distributions.jl` to generate species ranges and
phenologies that have prescribed statistical properties. This software is associated with the second preprinted version of _Catchen et
al. 2023_. 

`SpeciesInteractionNetworks.jl` makes use of `UnicodePlots.jl` to
make the REPL experience more interactive. If you would like to turn this off,
either to remove the slight added latency, or because you hate fun, you can set
the variable `SpeciesInteractionNetworks.INTERACTIVE_REPL = false`.

A brief description of the software can be found below, until more formal
documentation is written. 

# Types

`SpeciesInteractionNetworks.jl` (`SIS.jl` henceforth) contains types for
representing species interaction `Networks`, the `RelativeAbundance`
distribution of species within a local community, species' `Range`s, and species
`Phenology`s.

`SIS.jl` is designed around using the
[_traits_](https://ahsmart.com/pub/holy-traits-design-patterns-and-best-practice-book/)
design pattern for dispatch, made both possible and easy through
Julia's parametric polymorphism. Specifically, the primary way traits are used
in `SIS.jl` is as parameters of the `Network` data type. The two sets of
_traits_ each `Network` has are `Scale` and `State`. 

- The **`State`** trait represents the type of information contains within a
`Network`, and can take the values `Feasible`, `Possible`, `Realizable`,
`Realized`, `Detectable`, and `Detected`.  
- The **`Scale`** trait refers to the domain over which a `Network` is defined,
and can take the values of `Spatial`, `Temporal`, and `Spatiotemporal`,
or `Global`. 


# API

This is a brief description of the API design for `SIS.jl`


## `generate`

The `generate` method is used to (surprise) _generate_ many of the types of
data used by `SIS.jl` using different generation algorithms. The `generate` methods are used to create:
- `Network{Feasible,Global}` via `generate(::NetworkGenerator)`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    ```
    </details>
- `RelativeAbundance` via `generate(::RelativeAbundanceGenerator)`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)
    ```
    </details>
- `Range`s via `generate(::RangeGenerator)`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    range = generate(AutocorrelatedRange())

    # or to generate multiple...
    ranges = generate(AutocorrelatedRange(), 30)
    ```
    </details>
- `Phenology`s via `generate(::PhenologyGenerator)`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    phen = generate(UniformPhenology())

    # or to generate multiple...
    phens = generate(UniformPhenology(), 30)
    ```
    </details>
where different `GenerationAlgorithm`s are built-in or customized
types for generating different types of data. 


## `possible()`

Creates binary network of interactions that are _possible_ based on whether each species co-occurs at a given place/time.

- `possible(::Network{Feasible,<:Global}, ::OccupancySet{Phenology})` ->
  `Network{Possible,Temporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, phens)
    ```
    </details>

- `possible(::Network{Feasible,Global}, ::OccupancySet{Range})` ->
  `Network{Possible,Temporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    ranges = generate(AutocorrelatedRange(), 30)
    poss_nets = possible(metaweb, ranges)    
    ```
    </details>
- `possible(::Network{Feasible,Global}, ::OccupancySet{Range}, ::OccupancySet{Phenology})` -> `Network{Possible,Spatiotemporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    phens = generate(UniformPhenology(), 30)
    ranges = generate(AutocorrelatedRange(), 30)
    poss_nets = possible(metaweb, ranges, phens)    
    ```
    </details>

## `realizable`

Creates network with realization rates between species governed by some `RealizationModel`.

- realizable(::Network{Possible,Temporal}, ::RealizationModel) ->
`Network{Realizable,Temporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    realizable(poss_nets, realization_model)
    ```
    </details>


- realizable(::Network{Possible,Spatial}, ::RealizationModel) ->
  `Network{Realizable,Spatial}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    poss_nets = possible(metaweb, ranges)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    realizable(poss_nets, realization_model)
    ```
    </details>

- realizable(::Network{Possible,Spatiotemporal}, ::RealizationModel) ->
`Network{Realizable,Spatiotemporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, ranges, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    realizable(poss_nets, realization_model)
    ```
    </details>

## `realize`

- realize(::Network{Realizable,Spatial}) -> Network{Realized,Spatial}
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    poss_nets = possible(metaweb, ranges)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realize(rlzble)
    ```
    </details>

- realize(::Network{Realizable,Temporal}) -> Network{Realized,Temporal}
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realize(rlzble)
    ```
    </details>
- realize(::Network{Realizable,Spatiotemporal}) -> Network{Realized, Spatiotemporal}
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, ranges, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realize(rlzble)
    ```
    </details>

## `detectability` 

- `detectability(::Network{Feasible, <:Global}, ::DetectionModel) -> Network{Detectable,<:Global}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    detection_model = RelativeAbundanceScaled(relabd, 20.)
    detect_probs = detectability(metaweb, detection_model)
    ```
    </details>


## `detect`

- `detect(::Network{Realized, Spatial}, ::Network{Detectable,<:Global}) ->
  Network{Detected,Spatial}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    poss_nets = possible(metaweb, ranges)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realized_net = realize(rlzble)

    detection_model = RelativeAbundanceScaled(relabd, 20.)
    detect_net = detectability(metaweb, detection_model)

    detect(realized_net, detect_net)
    ```
    </details>

- `detect(::Network{Realized,Temporal}, ::Network{Detectable,<:Global}) ->
  Network{Detected,Temporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realized_net = realize(rlzble)

    detection_model = RelativeAbundanceScaled(relabd, 20.)
    detect_net = detectability(metaweb, detection_model)

    detect(realized_net, detect_net)
    ```
    </details>

- `detect(::Network{Realized,Spatiotemporal}, ::Network{Detectable,<:Global}) -> Network{Detected,Spatiotemporal}`
    <details>
    <summary>Code Example</summary>
    <br>

    ```julia
    metaweb = generate(NicheModel())
    relabd = generate(NormalizedLogNormal(), metaweb)

    ranges = generate(AutocorrelatedRange(), 30)
    phens = generate(UniformPhenology(), 30)
    poss_nets = possible(metaweb, ranges, phens)    

    realization_model = NeutrallyForbiddenLinks(relabd)
    rlzble = realizable(poss_nets, realization_model)
    realized_net = realize(rlzble)

    detection_model = RelativeAbundanceScaled(relabd, 20.)
    detect_net = detectability(metaweb, detection_model)

    detect(realized_net, detect_net)
    ```
    </details>

# Extending `SIS.jl` for custom models

coming soon..