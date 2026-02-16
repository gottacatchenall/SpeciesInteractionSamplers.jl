# # How to Add Species Phenologies

# This guide shows how to add species phenologies to a sampling pipeline.

using SpeciesInteractionSamplers
using CairoMakie

# ## Temporal Setup

# Create your species pool and metaweb:

pool = UnipartiteSpeciesPool(25)
metaweb = generate(NicheModel(0.12), pool)

# Define the number of time steps (e.g., 52 weeks):

n_times = 52

# ## Available Phenology Generators

# The package provides three phenology generators:
#
# | Generator | Description | Best for |
# |-----------|-------------|----------|
# | `PoissonPhenology` | Activity for Poisson-distributed duration | - |
# | `UniformPhenology` | Random start/end, uniform distribution | - |
# | `GaussianMixturePhenology` | Continuous activity with multiple peaks | Continuous variation in density |

# ## Using PoissonPhenology

# Species are active for a continuous period with Poisson-distributed length:

# Short activity periods (mean = 5 time steps):
short_phens = generate(PoissonPhenology(5), pool, n_times)

# Long activity periods (mean = 20 time steps):
long_phens = generate(PoissonPhenology(20), pool, n_times)


# fig-phenologies
fig = Figure(size=(700, 300))
ax1 = Axis(fig[1,1], title="Short Phenologies (μ=5)", xlabel="Time", ylabel="Species")
heatmap!(ax1, Matrix(parent(short_phens))', colormap=[:white, :steelblue])
ax2 = Axis(fig[1,2], title="Long Phenologies (μ=20)", xlabel="Time", ylabel="Species")
heatmap!(ax2, Matrix(parent(long_phens))', colormap=[:white, :steelblue])
fig #hide

# Now let's consider phenologies that reflect density, instead of binary occurrence.
# 

# ## Using GaussianMixturePhenology

# Creates continuous activity patterns with multiple peaks - useful for species that have varying activity levels rather than binary presence/absence.

using Distributions

# Single-peaked activity:
single_peak = generate(
    GaussianMixturePhenology(
        mean_distribution=Normal(0.5, 0.1),  # Peak near middle
        std_distribution=Truncated(Normal(0.1, 0.05), 0.05, Inf),
        num_components=1
    ),
    pool,
    n_times
)

# Multi-peaked activity (e.g., spring and fall activity):
multi_peak = generate(
    GaussianMixturePhenology(
        mean_distribution=Uniform(0, 1),
        std_distribution=Truncated(Normal(0.1, 0.05), 0.05, Inf),
        num_components=3
    ),
    pool,
    n_times
)

# fig-multi-peak
fig2 = Figure(size=(700, 300))
ax1 = Axis(fig2[1,1], title="Single Peak", xlabel="Time", ylabel="Species")
heatmap!(ax1, Matrix(parent(single_peak))', colormap=:viridis)
ax2 = Axis(fig2[1,2], title="Multiple Peaks", xlabel="Time", ylabel="Species")
heatmap!(ax2, Matrix(parent(multi_peak))', colormap=:viridis)
fig2 #hide

# Now let's use these for sampling
# 

# ## Creating a Temporal Context

# Wrap phenologies in a `SpatiotemporalContext`:

phenologies = generate(PoissonPhenology(10), pool, n_times)
context = SpatiotemporalContext(phenologies)

# ## Filtering to Potential Interactions

# Use `possibility()` to filter based on phenological overlap:

potential = possibility(metaweb, context)

# The potential network now has a time dimension:

println("Original metaweb: $(size(metaweb.data))")
println("Potential network: $(size(potential.data))")

# ## Combining Space and Time

# You can add both spatial and temporal constraints:

dims = (30, 30)
ranges = generate(AutocorrelatedRange(), pool, dims)

full_context = SpatiotemporalContext(ranges, phenologies)
potential_st = possibility(metaweb, full_context)

println("Spatiotemporal network: $(size(potential_st.data))")
println("Dimensions: species × species × x × y × time")

# ## Phenologies for Bipartite Networks

# Phenologies work the same way for bipartite networks:

bipartite_pool = BipartiteSpeciesPool(10, 15; partition_names=[:plants, :pollinators])

# Different phenology patterns for each partition:
plant_phens = generate(PoissonPhenology(15), bipartite_pool, n_times)

# ## Running the Full Pipeline with Phenologies

abundances = generate(LogNormalAbundance(), pool)

# Pipeline with temporal constraints:
potential = possibility(metaweb, context)
realized = realize(potential, MassActionRealization(abundances; energy=500))
detected = detect(realized, AbundanceScaledDetection(abundances))

# Aggregate across time:
total_detected = dropdims(sum(detected.data, dims=3), dims=3)
completeness = sum(total_detected .> 0) / sum(metaweb.data)
println("Sampling completeness: $(round(completeness * 100, digits=1))%")