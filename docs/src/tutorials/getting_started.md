# Getting Started with `SpeciesInteractionSamplers.jl`

Load the package.

```@example 1
using SpeciesInteractionSamplers
using CairoMakie
```

Generate a network

```@example 1
net = generate(NicheModel())
```



Make it realizable, first by generating a relative abundance distribution

```@example 1 
relabd = generate(NormalizedLogNormal(), net)
```

foo

```@example 1
realization_model = NeutrallyForbiddenLinks(relabd, 100.)
θ = realizable(net, realization_model)
```

foo

```@example 1
ζ = realize(θ)
```


foo

```@example 1
detection_model = RelativeAbundanceScaled(relabd, 10)
δ = detectability(net, detection_model)
```

foo

```@example 1
detect(ζ, δ)
```

foo

```@example 1
p = generate(UniformPhenology(), 30)
possible(net, p)
```
