# # Getting Started with `SpeciesInteractionSamplers.jl`

# Load the package.

using SpeciesInteractionSamplers
using CairoMakie

# Generate a network

pool = UnipartiteSpeciesPool(30)
net = generate(NicheModel(0.1), pool)


