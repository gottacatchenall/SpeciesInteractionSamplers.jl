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

```@ansi 1 
relabd = generate(NormalizedLogNormal(), net)
```

foo

```@example 1
realization_model = NeutrallyForbiddenLinks(100.)
realizable!(realization_model, net, relabd)
```

foo

```@example 1
realize!(net)
```


foo

```@example 1
detection_model = RelativeAbundanceScaled(10)
δ = detectability(detection_model, net, relabd)
```

foo

```@example 1
detect!(net, δ)
```

foo

```@example 1
p = generate(UniformPhenology(), 30)
possible(net, p)
```
