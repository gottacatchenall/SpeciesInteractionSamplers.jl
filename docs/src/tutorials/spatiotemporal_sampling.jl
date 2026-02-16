# # Spatiotemporal Sampling

# This tutorial shows how to simulate interaction sampling across space and time.
# Species don't occur everywhere or at all times - their ranges and phenologies
# constrain when and where interactions can occur.

# ## The Potential Stage

# Recall the four-stage pipeline: Feasible → Potential → Realized → Detected.
#
# The **Potential** stage is where spatiotemporal constraints come in. An interaction is potential (can occur) at a given location and time only if:
#
# 1. The interaction is feasible (exists in the metaweb)
# 2. Both species' ranges overlap at that location
# 3. Both species' phenologies overlap at that time

# ## Setup

using SpeciesInteractionSamplers
using CairoMakie

# Create a species pool and metaweb:

pool = UnipartiteSpeciesPool(25)
metaweb = generate(NicheModel(0.12), pool)

println("Feasible interactions: $(sum(metaweb.data))")

# ## Adding Spatial Structure with Ranges

# Species ranges define where each species can occur. We use `AutocorrelatedRange` to generate realistic range maps with spatial autocorrelation.

# Define landscape dimensions:

dims = (50, 50)

# Generate ranges for all species:

ranges = generate(AutocorrelatedRange(), pool, dims)

# The `AutocorrelatedRange` generator has two key parameters:
# - `autocorrelation` (0-1): Higher values create smoother, more continuous ranges
# - `prevalence`: Controls what proportion of the landscape each species occupies

# Let's visualize a few species' ranges:

# fig-ranges
fig = Figure(size=(800, 300))
for (i, sp_idx) in enumerate([1, 5, 10])
    ax = Axis(fig[1,i], title="Species $sp_idx", aspect=1)
    heatmap!(ax, parent(ranges)[sp_idx, :, :], colormap=[:white, :forestgreen])
end
fig #hide

# 
# Now we'll integrate them into the sampling pipeline.

# ## Creating a Spatial Context

# Wrap the ranges in a `SpatiotemporalContext`:

spatial_context = SpatiotemporalContext(ranges)

# ## Filtering to Potential Interactions

# Use `possibility()` to filter the metaweb to only include interactions that can occur given the spatial context:

potential = possibility(metaweb, spatial_context)

# The potential network now has spatial dimensions:

println("Potential network dimensions: $(size(potential.data))")
println("Dimensions: species × species × x × y")

# ## Visualizing Spatial Variation

# Let's see how the number of potential interactions varies across the landscape:

potential_per_location = dropdims(sum(potential.data, dims=(1,2)), dims=(1,2));

# fig-potential
fig2 = Figure()
ax = Axis(fig2[1,1], title="Potential Interactions per Location", aspect=1)
hm = heatmap!(ax, potential_per_location, colormap=:viridis)
Colorbar(fig2[1,2], hm, label="Number of potential interactions")
fig2 #hide

# Now we'll move to realization of interactions in space.
# 


# ## Realizing and Detecting with Spatial Structure

# Generate abundances and run through the full pipeline:

abundances = generate(LogNormalAbundance(), pool)

realized = realize(potential, MassActionRealization(abundances; energy=1000))
detected = detect(realized, AbundanceScaledDetection(abundances))

# Aggregate detections across space:

detected_per_interaction = dropdims(sum(detected.data, dims=(3,4)), dims=(3,4))
unique_detected = sum(detected_per_interaction .> 0)

println("Unique interactions detected: $unique_detected")
println("Completeness: $(round(unique_detected / sum(metaweb.data) * 100, digits=1))%")

# ## Adding Temporal Structure with Phenologies

# Species phenologies define when each species is active. Let's add temporal constraints to our simulation.

n_timesteps = 52  # e.g., weeks in a year

# Generate phenologies using a Poisson distribution for activity period length:

phenologies = generate(PoissonPhenology(10), pool, n_timesteps)

# Visualize some species' phenologies:

# fig-phenologies
fig3 = Figure(size=(800, 300))
ax = Axis(fig3[1,1],
    xlabel="Time",
    ylabel="Species",
    title="Species Phenologies")
heatmap!(ax, Matrix(parent(phenologies))[:, :]', colormap=[:white, :steelblue])
fig3 #hide

# Now we'll combine species ranges and phenologies
#

# ## Full Spatiotemporal Context

# Combine ranges and phenologies:

full_context = SpatiotemporalContext(ranges, phenologies)

# Filter to potential interactions:

potential_st = possibility(metaweb, full_context)

# Now the network has both spatial and temporal dimensions:

println("Spatiotemporal network dimensions: $(size(potential_st.data))")
println("Dimensions: species × species × x × y × time")

# and we can simulate sampling

realized_st = realize(potential_st, MassActionRealization(abundances; energy=500))
detected_st = detect(realized_st, AbundanceScaledDetection(abundances))

# ## Different Phenology Generators

# The package provides several phenology generators:

# **UniformPhenology** - Random start and end times, uniformly distributed:

phens_uniform = generate(UniformPhenology(), pool, n_timesteps)

# **GaussianMixturePhenology** - Continuous activity with multiple peaks:

phens_gaussian = generate(GaussianMixturePhenology(num_components=2), pool, n_timesteps)

# Compare them:

# fig-generators
fig5 = Figure(size=(800, 400))
ax1 = Axis(fig5[1,1], title="Poisson Phenology", xlabel="Time", ylabel="Species", aspect=1)
heatmap!(ax1, Matrix(parent(phenologies))', colormap=:viridis)
ax2 = Axis(fig5[1,2], title="Uniform Phenology", xlabel="Time", ylabel="Species", aspect=1)
heatmap!(ax2, Matrix(parent(phens_uniform))', colormap=:viridis)
ax3 = Axis(fig5[1,3], title="Gaussian Mixture Phenology", xlabel="Time", ylabel="Species", aspect=1)
heatmap!(ax3, Matrix(parent(phens_gaussian))', colormap=:viridis)
fig5 #hide

# Now let's discuss adjusting range generators 
#

# ## Customizing Range Properties

# You can adjust range properties:

# More autocorrelated (smoother) ranges with lower prevalence:

smooth_ranges = generate(
    AutocorrelatedRange(autocorrelation=0.99, prevalence=0.2),
    pool,
    dims
)

# Less autocorrelated (patchier) ranges with higher prevalence:

patchy_ranges = generate(
    AutocorrelatedRange(autocorrelation=0.3, prevalence=0.7),
    pool,
    dims
)

# fig-range-generators
fig6 = Figure(size=(600, 300))
ax1 = Axis(fig6[1,1], title="Smooth, Rare Ranges", aspect=1)
heatmap!(ax1, parent(smooth_ranges)[1, :, :], colormap=[:white, :forestgreen])
ax2 = Axis(fig6[1,2], title="Patchy, Common Ranges", aspect=1)
heatmap!(ax2, parent(patchy_ranges)[1, :, :], colormap=[:white, :forestgreen])
fig6 #hide 
