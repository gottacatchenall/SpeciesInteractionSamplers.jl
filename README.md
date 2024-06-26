# SpeciesInteractionSamplers.jl

[![DOC](https://img.shields.io/badge/Documentation-blue?style=flat-square)](https://gottacatchenall.github.io/SpeciesInteractionSamplers.jl)

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

The documentation can be found [here](https://gottacatchenall.github.io/SpeciesInteractionSamplers.jl)

# A Sampled Interaction Network from Scratch in 7 Lines

```julia
using SpeciesInteractionSamplers

feasible_network = generate(NicheModel())
relative_abundance = generate(NormalizedLogNormal(σ=0.2), λ)

energy = 500
realization_rate = realizable(feasible_network, NeutrallyForbiddenLinks(relative_abundance, energy))
realized_network = realize(θ)

detectability_network = detectability(λ, RelativeAbundanceScaled(relative_abundance, 10.0))
detected_network = detect(ζ, δ)
```

# API Design

A thorough description of the `SpeciesInteractionSamplers.jl` API can be found in the documentation. A diagram conveying the essentials can be seen below.

![](https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/main/docs/src/design.png)
