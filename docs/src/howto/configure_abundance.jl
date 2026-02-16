# # How to Configure Abundances

# This guide shows how to generate and configure species abundance distributions, which control interaction rates and detection probabilities.

using SpeciesInteractionSamplers
using CairoMakie
using Distributions
using Statistics
# ## Setup

pool = UnipartiteSpeciesPool(30)

# ## Using LogNormalAbundance

# The log-normal is a classic species abundance distribution with many rare species and few common ones.

# Default parameters:
lognormal_default = generate(LogNormalAbundance(), pool)

# More variation (higher σ means less even):
lognormal_uneven = generate(LogNormalAbundance(σ=2.0), pool)

# Less variation (lower σ means more even):
lognormal_even = generate(LogNormalAbundance(σ=0.5), pool)

# Visualize:

# fig-lognormal
fig_lognorm = Figure(size=(700, 300))
ax1 = Axis(fig_lognorm[1,1], title="Even (σ=0.5)", xlabel="Species rank", ylabel="Relative abundance")
barplot!(ax1, 
    sort(collect(collect(parent(lognormal_even))), rev=true)
)
ax2 = Axis(fig_lognorm[1,2], title="Default (σ=1.0)", xlabel="Species rank", ylabel="Relative abundance")
barplot!(ax2, sort(collect(collect(parent(lognormal_default))), rev=true))
ax3 = Axis(fig_lognorm[1,3], title="Uneven (σ=2.0)", xlabel="Species rank", ylabel="Relative abundance")
barplot!(ax3, sort(collect(collect(parent(lognormal_uneven))), rev=true))
fig_lognorm #hide

# ## Using Custom Distributions

# `DistributionBasedAbundance` lets you use any distribution from Distributions.jl:

# Uniform abundance (all species equal):
uniform_abund = generate(DistributionBasedAbundance(Uniform(0.5, 1.5)), pool)

# Gamma distribution:
gamma_abund = generate(DistributionBasedAbundance(Gamma(2, 1)), pool)

# Note: Abundances are normalized to sum to 1 (relative abundances)

# ## Abundances for Bipartite Networks

# For bipartite networks, abundances are generated for each partition:

bipartite_pool = BipartiteSpeciesPool(15, 20; partition_names=[:plants, :pollinators])
bipartite_abund = generate(LogNormalAbundance(σ=1.5), bipartite_pool)

# The abundances are stored per partition:
println("Abundance structure: $(typeof(bipartite_abund.data))")

# ## Effect on Realization

# Let's see how abundance distribution affects realized interactions:

metaweb = generate(NicheModel(0.15), pool)

# Compare even vs uneven abundance:
realized_even = realize(metaweb, MassActionRealization(lognormal_even; energy=500))
realized_uneven = realize(metaweb, MassActionRealization(lognormal_uneven; energy=500))

println("Unique interactions (even abundances): $(sum(realized_even.data .> 0))")
println("Unique interactions (uneven abundances): $(sum(realized_uneven.data .> 0))")

# Uneven abundances typically lead to fewer unique realized interactions
# because rare species have very low encounter rates.

# ## Effect on Detection

# Detection is also affected by abundance:

detected_even = detect(realized_even, AbundanceScaledDetection(lognormal_even, scaling_mode = ExponentialDetectability(50.)))
detected_uneven = detect(realized_uneven, AbundanceScaledDetection(lognormal_uneven, scaling_mode = ExponentialDetectability(50.)))

completeness_even = sum(detected_even.data .> 0) / sum(metaweb.data)
completeness_uneven = sum(detected_uneven.data .> 0) / sum(metaweb.data)

println("Completeness (even): $(round(completeness_even * 100, digits=1))%")
println("Completeness (uneven): $(round(completeness_uneven * 100, digits=1))%")
