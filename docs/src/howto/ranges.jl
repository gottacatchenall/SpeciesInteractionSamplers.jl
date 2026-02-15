# # How to Add Species Ranges

# This guide shows how to add species ranges to your simulation so that interactions can only occur where both species co-occur.

using SpeciesInteractionSamplers
using CairoMakie
using Distributions

# ## Basic Spatial Setup

# First, create your species pool and metaweb:

pool = UnipartiteSpeciesPool(20)
metaweb = generate(NicheModel(0.15), pool)

# Define the landscape dimensions (x × y grid):

dims = (40, 40)

# Generate ranges using `AutocorrelatedRange`:

ranges = generate(AutocorrelatedRange(), pool, dims)

# ## Understanding AutocorrelatedRange

# `AutocorrelatedRange` creates realistic species distributions using the
# Diamond-Square algorithm. Two parameters control the output:

# **autocorrelation** (0-1): Controls spatial smoothness
# - Low values → patchy, fragmented ranges
# - High values → smooth, continuous ranges

# **prevalence**: Controls what fraction of landscape is occupied
# - Can be a fixed number or a distribution
# - Default is `Beta(10, 10)` (mean ~0.5)

# ## Customizing Range Properties

# Create ranges with different properties:

# Smooth, widespread ranges:
widespread_gen = AutocorrelatedRange(autocorrelation=0.9, prevalence=Beta(15, 5))

# Patchy, restricted ranges:
restricted_gen = AutocorrelatedRange(autocorrelation=0.5, prevalence=Beta(3, 10))

# Fixed prevalence (all species occupy ~30% of landscape):
fixed_gen = AutocorrelatedRange(autocorrelation=0.8, prevalence=0.3)

# Generate and compare:
widespread_ranges = generate(widespread_gen, pool, dims)
restricted_ranges = generate(restricted_gen, pool, dims)

# fig-widespread-restricted
fig = Figure(size=(600, 300))
ax1 = Axis(fig[1,1], title="Widespread Species", aspect=1)
heatmap!(ax1, parent(widespread_ranges)[1, :, :], colormap=[:white, :forestgreen])
ax2 = Axis(fig[1,2], title="Restricted Species", aspect=1)
heatmap!(ax2, parent(restricted_ranges)[1, :, :], colormap=[:white, :forestgreen])
fig #hide

# ## Creating a Spatial Context

# Wrap the ranges in a `SpatiotemporalContext`:

context = SpatiotemporalContext(ranges)

# ## Filtering to Potential Interactions

# Use `possibility()` to get the potential network:

potential = possibility(metaweb, context)

# The potential network now has spatial dimensions (species × species × x × y):

println("Original metaweb: $(size(metaweb.data))")
println("Potential network: $(size(potential.data))")

# ## Visualizing Range Overlap

# An interaction is only possible where both species' ranges overlap.
# Let's visualize this for one species pair:

sp1, sp2 = 1, 5

# fig-overlap
fig2 = Figure(size=(800, 300))
ax1 = Axis(fig2[1,1], title="Species $sp1 Range", aspect=1)
heatmap!(ax1, parent(ranges)[sp1, :, :], colormap=[:white, :blue])
ax2 = Axis(fig2[1,2], title="Species $sp2 Range", aspect=1)
heatmap!(ax2, parent(ranges)[sp2, :, :], colormap=[:white, :red])
ax3 = Axis(fig2[1,3], title="Overlap (interaction possible)", aspect=1)
overlap = parent(ranges)[sp1, :, :] .& parent(ranges)[sp2, :, :]
heatmap!(ax3, overlap, colormap=[:white, :purple])
fig2 #hide

# ## Calculating Spatial Metrics

# Calculate mean range size:

mean_range_size = mean(sum(parent(ranges)[i, :, :]) for i in 1:numspecies(pool))
println("Mean range size: $(round(mean_range_size, digits=1)) cells")
println("Mean prevalence: $(round(mean_range_size / prod(dims) * 100, digits=1))%")

# Calculate mean pairwise overlap:

n_species = numspecies(pool)
overlaps = Float64[]
for i in 1:n_species
    for j in (i+1):n_species
        overlap_area = sum(parent(ranges)[i, :, :] .& parent(ranges)[j, :, :])
        push!(overlaps, overlap_area)
    end
end
println("Mean pairwise overlap: $(round(mean(overlaps), digits=1)) cells")

# ## Ranges for Bipartite Networks

# Ranges work the same way for bipartite networks:

bipartite_pool = BipartiteSpeciesPool(10, 15; partition_names=[:plants, :pollinators])
bipartite_ranges = generate(AutocorrelatedRange(), bipartite_pool, dims)

# Each partition gets its own set of ranges:

println("Range data structure: $(typeof(bipartite_ranges.data))")

# ## Using Spatial Context in the Pipeline

# Complete example with spatial constraints:

abundances = generate(LogNormalAbundance(), pool)

# Full pipeline with space:
potential = possibility(metaweb, context)
realized = realize(potential, MassActionRealization(abundances; energy=500))
detected = detect(realized, AbundanceScaledDetection(abundances))

# Aggregate across space to get total detected:
total_detected = dropdims(sum(detected.data, dims=(3,4)), dims=(3,4))
completeness = sum(total_detected .> 0) / sum(metaweb.data)
println("Sampling completeness: $(round(completeness * 100, digits=1))%")


# # TK: Sampling Locations 