# # Getting Started with SpeciesInteractionSamplers.jl

# This tutorial introduces the core concepts and workflow of `SpeciesInteractionSamplers.jl`. By the end, you'll understand the four-stage sampling pipeline and how to simulate the observation of species interaction networks.

# ## Installation

# You can install SpeciesInteractionSamplers.jl using the Julia package manager:

# ```julia
# using Pkg
# Pkg.add("SpeciesInteractionSamplers")
# ```

# ## Loading the Package

using SpeciesInteractionSamplers
using CairoMakie

# ## The Sampling Pipeline

# The package models species interaction sampling as a four-stage pipeline:
#
# 1. **Feasible** - All biologically possible interactions between species
# 2. **Potential** - Interactions that can occur given spatiotemporal co-occurrence
# 3. **Realized** - Interactions that actually happen (stochastic process)
# 4. **Detected** - Interactions that are observed by a sampling effort
#
# Each stage transforms the network, progressively filtering from all possible interactions down to what we actually observe in the field.

# ## Step 1: Create a Species Pool

# First, we define a pool of species. For a simple food web, we use a `UnipartiteSpeciesPool` where any species can potentially interact with any other.

pool = UnipartiteSpeciesPool(30)

# ## Step 2: Generate a Feasible Network

# The feasible network represents all biologically possible interactions. We use the Niche Model to generate a realistic food web structure with a target connectance (proportion of possible interactions that exist).

metaweb = generate(NicheModel(0.15), pool)

# The `metaweb` is a `NetworkLayer` in the `Feasible` state. Let's see how many interactions exist:

num_interactions = sum(metaweb.data)
println("Feasible interactions: $num_interactions")

# ## Step 3: Generate Species Abundances

# Species abundances determine how likely interactions are to occur and be detected. A log-normal distribution produces realistic abundance patterns with many rare species and few common ones.

abundances = generate(LogNormalAbundance(), pool)

# ## Step 4: Realize Interactions

# Not all feasible interactions happen - they depend on encounter rates determined by species abundances. The `MassActionRealization` model simulates this using a Poisson process where rates scale with the abundances of both species.

# The `energy` parameter controls total interaction intensity:

realized = realize(metaweb, MassActionRealization(abundances; energy=500))

unique_realized = sum(realized.data .> 0)
println("Unique realized interactions: $unique_realized")

# ## Step 5: Detect Interactions

# Finally, not all realized interactions are detected. Detection probability often scales with species abundance - interactions involving rare species are harder to observe.

detected = detect(realized, AbundanceScaledDetection(abundances))

unique_detected = sum(detected.data .> 0)
total_detected = sum(detected.data)
println("Unique detected interactions: $unique_detected")
println("Total detected interaction events: $total_detected")

# ## Visualizing the Pipeline

# Let's visualize how the network changes through the pipeline:

# fig-pipeline
fig = Figure(size=(800, 300))
ax1 = Axis(fig[1,1], title="Feasible", aspect=1,
    xlabel="Species", ylabel="Species")
heatmap!(ax1, SpeciesInteractionSamplers.interactions(metaweb) .> 0, colormap=[:white, :black])
ax2 = Axis(fig[1,2], title="Realized", aspect=1,
    xlabel="Species", ylabel="Species")
heatmap!(ax2, SpeciesInteractionSamplers.interactions(realized) .> 0, colormap=[:white, :steelblue])
ax3 = Axis(fig[1,3], title="Detected", aspect=1,
    xlabel="Species", ylabel="Species")
heatmap!(ax3, SpeciesInteractionSamplers.interactions(detected) .> 0, colormap=[:white, :forestgreen])
fig #hide


# ## Calculating Sampling Completeness

# A key metric is sampling completeness - what fraction of feasible interactions did we detect?

completeness = unique_detected / num_interactions
println("Sampling completeness: $(round(completeness * 100, digits=1))%")

# ## Effect of Sampling Effort

# Let's see how completeness changes with the total number of detected interactions by varying the `energy` parameter:

energies = [10^i for i in 2:0.5:6]
completeness_values = Float64[]
detected_values = Float64[]

for e in energies
    realized_e = realize(metaweb, MassActionRealization(abundances; energy=e))
    detected_e = detect(realized_e, AbundanceScaledDetection(abundances))
    push!(detected_values, sum(detected_e.data))
    push!(completeness_values, sum(detected_e.data .> 0) / num_interactions)
end

# fig-completeness
fig2 = Figure()
ax = Axis(fig2[1,1],
    xlabel="Total Detected Interactions",
    ylabel="Sampling Completeness",
    xscale=log10,
)
scatterlines!(ax, detected_values, completeness_values, markersize=12)
fig2 #hide

# ## Next Steps

# Now that you understand the basic pipeline, you can explore:
#
# - [**Adding spatial structure**](howto/ranges) with `Ranges` and `AutocorrelatedRange`
# - [**Adding temporal structure**](howto/phenologies) with `Phenologies`
# - [**Bipartite networks**](tutorials/bipartite_networks) (e.g., plant-pollinator) with `BipartiteSpeciesPool`
# - [**Different realization models](howto/realization_models)
# - [**Different detection models**](howto/detection_models) 
#
# See the other tutorials and how-to guides for more details.
