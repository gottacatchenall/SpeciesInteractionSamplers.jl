# SpeciesInteractionSamplers.jl

Documentation for `SpeciesInteractionSamplers.jl`.

```@setup 1
using SpeciesInteractionSamplers
```

```@repl 1
energy = 200
λ = generate(NicheModel())
relabd = generate(NormalizedLogNormal(σ=0.2), λ)
θ = realizable(λ, NeutrallyForbiddenLinks(relabd, energy))
ζ = realize(θ)

δ = detectability(λ, RelativeAbundanceScaled(relabd, 20.))

detect(ζ, δ)
```
