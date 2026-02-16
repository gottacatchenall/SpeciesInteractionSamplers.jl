# # How to Configure Realization Models

# This guide shows how to configure realization models that control how potential interactions become actual interaction events.

using SpeciesInteractionSamplers
using CairoMakie
using Statistics

const SIS = SpeciesInteractionSamplers

# ## Realization in the Pipeline

# The realization stage transforms Feasible/Potential → Realized. Each potential interaction occurs some number of times based on a Poisson process where the rate depends on species abundances.

# ## Setup

pool = UnipartiteSpeciesPool(30)
metaweb = generate(NicheModel(0.15), pool)
abundances = generate(LogNormalAbundance(), pool)

println("Feasible interactions: $(sum(metaweb.data))")

# ## The MassActionRealization Model

# `MassActionRealization` is the main realization model. It simulates interactions as a stochastic process where encounter rate depends on both species' abundances.

# The number of interactions follows: Poisson(θᵢⱼ), where θᵢⱼ = energy * f(abundanceᵢ, abundanceⱼ)

# ## The Energy Parameter

# Energy controls the expected total number of interaction events. Higher energy means more interactions occur:

realized_low = realize(metaweb, MassActionRealization(abundances; energy=100))
realized_med = realize(metaweb, MassActionRealization(abundances; energy=1000))
realized_high = realize(metaweb, MassActionRealization(abundances; energy=10000))

println("Low energy (100): $(sum(realized_low.data)) total events, $(sum(realized_low.data .> 0)) unique")
println("Medium energy (1000): $(sum(realized_med.data)) total events, $(sum(realized_med.data .> 0)) unique")
println("High energy (10000): $(sum(realized_high.data)) total events, $(sum(realized_high.data .> 0)) unique")

# Visualize the relationship between energy and interactions:

energies = [10, 50, 100, 500, 1000, 5000, 10000]
total_events = Float64[]
unique_interactions = Float64[]

for e in energies
    real = realize(metaweb, MassActionRealization(abundances; energy=e))
    push!(total_events, sum(real.data))
    push!(unique_interactions, sum(real.data .> 0))
end

# fig-energy
fig = Figure()
ax1 = Axis(fig[1,1], xlabel="Energy", ylabel="Unique Interactions", xscale=log10)
scatterlines!(ax1, energies, unique_interactions, markersize=10)
hlines!(ax1, [sum(metaweb.data)], linestyle=:dash, color=:gray, label="Max possible")
fig #hide

# ## Abundance Combination Modes

# The combination mode determines how to combine the abundances of two species to calculate the interaction rate.

# **AbundanceProduct** (default): Rate ∝ aᵢ * aⱼ
# - Classic mass-action assumption
# - Common species dominate interactions

# **AbundanceMin**: Rate ∝ min(aᵢ, aⱼ)
# - Rate limited by the rarer species

# **AbundanceMax**: Rate ∝ max(aᵢ, aⱼ)
# - Rate driven by the more common species

# **AbundanceMean**: Rate ∝ (aᵢ + aⱼ)/2
# - Balanced between both species

# **AbundanceGeometricMean**: Rate ∝ sqrt(aᵢ * aⱼ)
# - Geometric mean of abundances

real_product = realize(
    metaweb, 
    MassActionRealization(
        abundances;
        energy=1000, 
        combination_mode=AbundanceProduct()
    )
)

real_min = realize(
    metaweb, 
    MassActionRealization(
        abundances;
        energy=1000, 
        combination_mode=AbundanceMin()
    )
)

real_max = realize(
    metaweb,
    MassActionRealization(
        abundances;
        energy=1000, 
        combination_mode=AbundanceMax()
    )
)

real_mean = realize(
    metaweb, 
    MassActionRealization(
        abundances;
        energy=1000, 
        combination_mode=AbundanceMean()
    )
)

println("Product: $(sum(real_product.data .> 0)) unique interactions")
println("Min: $(sum(real_min.data .> 0)) unique interactions")
println("Max: $(sum(real_max.data .> 0)) unique interactions")
println("Mean: $(sum(real_mean.data .> 0)) unique interactions")

# ## Visualizing Combination Modes

# See how different modes distribute interactions:

# fig-combination-modes
fig2 = Figure(size=(800, 400))
ax1 = Axis(fig2[1,1], title="Product", xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax1, log10.(SIS.interactions(real_product) .+ 1), colormap=:viridis)
ax2 = Axis(fig2[1,2], title="Min", xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax2, log10.(SIS.interactions(real_min) .+ 1), colormap=:viridis)
ax3 = Axis(fig2[2,1], title="Max", xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax3, log10.(SIS.interactions(real_max) .+ 1), colormap=:viridis)
ax4 = Axis(fig2[2,2], title="Mean", xlabel="Species", ylabel="Species", aspect=1)
hm = heatmap!(ax4, log10.(SIS.interactions(real_mean) .+ 1), colormap=:viridis)
Colorbar(fig2[:, 3], hm, label="log10(events + 1)")
fig2 #hide

# ## Comparing Realization Across Abundance Distributions

# The effect of combination mode depends on the abundance distribution:

# Even abundances:
even_abund = generate(LogNormalAbundance(σ=0.3), pool)
real_even_product = realize(metaweb, MassActionRealization(even_abund;
    energy=1000, combination_mode=AbundanceProduct()))
real_even_min = realize(metaweb, MassActionRealization(even_abund;
    energy=1000, combination_mode=AbundanceMin()))

# Uneven abundances:
uneven_abund = generate(LogNormalAbundance(σ=2.0), pool)
real_uneven_product = realize(metaweb, MassActionRealization(uneven_abund;
    energy=1000, combination_mode=AbundanceProduct()))
real_uneven_min = realize(metaweb, MassActionRealization(uneven_abund;
    energy=1000, combination_mode=AbundanceMin()))

println("\nEven abundances (σ=0.3):")
println("  Product: $(sum(real_even_product.data .> 0)) unique")
println("  Min: $(sum(real_even_min.data .> 0)) unique")

println("\nUneven abundances (σ=2.0):")
println("  Product: $(sum(real_uneven_product.data .> 0)) unique")
println("  Min: $(sum(real_uneven_min.data .> 0)) unique")

# With uneven abundances, the choice of combination mode matters more.

# ## Realization for Bipartite Networks

# Realization works the same way for bipartite networks:

bipartite_pool = BipartiteSpeciesPool(15, 20; partition_names=[:plants, :pollinators])
bipartite_metaweb = generate(ErdosRenyi(0.2), bipartite_pool)
bipartite_abund = generate(LogNormalAbundance(), bipartite_pool)

bipartite_realized = realize(
    bipartite_metaweb,
    MassActionRealization(
        bipartite_abund; 
        energy=1000
    )
)

println("\nBipartite realized: $(sum(bipartite_realized.data)) events")
println("Unique interactions: $(sum(bipartite_realized.data .> 0))")

# ## Trait-Based Realization Models

# In addition to mass-action dynamics, interactions can be driven by trait similarity between species. Species with similar trait vectors are more likely to interact, modulated by a kernel function.

# ### Setting Up Trait Matrices with InteractionTraits

# `InteractionTraits` wraps a species-by-traits matrix. Each row is a species
# and each column is a trait dimension:

trait_matrix = randn(30, 3)  # 30 species, 3 trait dimensions
traits = InteractionTraits(trait_matrix, pool)

# ### Kernel Functions

# Kernel functions transform pairwise Euclidean distances between trait vectors into interaction affinities (values between 0 and 1). Currently there is **GaussianKernel(σ)** and **ExponentialKernel(σ)**

# Visualize kernel shapes:

distances = range(0, 5, length=100)

# fig-kernels
fig_kernels = Figure(size=(600, 300))
ax_k = Axis(fig_kernels[1, 1], xlabel="Trait distance", ylabel="Affinity",
    title="Kernel Functions")
for (σ, ls) in [(0.5, :dash), (1.0, :solid), (2.0, :dot)]
    lines!(ax_k, collect(distances), GaussianKernel(σ).(distances),
        label="Gaussian σ=$σ", linestyle=ls, color=:blue)
    lines!(ax_k, collect(distances), ExponentialKernel(σ).(distances),
        label="Exponential σ=$σ", linestyle=ls, color=:red)
end
axislegend(ax_k, position=:rt)
fig_kernels #hide

# ### TraitMatchingRealization

# `TraitMatchingRealization` uses only trait similarity to determine interaction rates. No abundance information is needed.

# θᵢⱼ = energy × kernel(‖traitᵢ - traitⱼ‖) × possible

real_trait_narrow = realize(metaweb,
    TraitMatchingRealization(traits; energy=1000, kernel=GaussianKernel(0.5)))

real_trait_wide = realize(metaweb,
    TraitMatchingRealization(traits; energy=1000, kernel=GaussianKernel(2.0)))

println("Narrow kernel (σ=0.5): $(sum(real_trait_narrow.data .> 0)) unique interactions")
println("Wide kernel (σ=2.0): $(sum(real_trait_wide.data .> 0)) unique interactions")

# A narrow kernel concentrates interactions among trait-similar species, while a wide kernel allows more dissimilar species to interact.

# Compare narrow vs. wide kernel effects:


# fig-trait-realization
fig_trait = Figure(size=(800, 350))
ax_t1 = Axis(fig_trait[1,1], title="Gaussian σ=0.5 (narrow)",
    xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax_t1, log10.(SIS.interactions(real_trait_narrow) .+ 1), colormap=:viridis)
ax_t2 = Axis(fig_trait[1,2], title="Gaussian σ=2.0 (wide)",
    xlabel="Species", ylabel="Species", aspect=1)
hm_t = heatmap!(ax_t2, log10.(SIS.interactions(real_trait_wide) .+ 1), colormap=:viridis)
Colorbar(fig_trait[:, 3], hm_t, label="log10(events + 1)")
fig_trait #fig

# ### TraitAbundanceRealization

# `TraitAbundanceRealization` combines mass-action abundance with trait-matching. This captures the ecological idea that interactions require both encounter opportunity (abundance) and trait compatibility.

real_combined = realize(
    metaweb,
    TraitAbundanceRealization(
        abundances, 
        traits;
        energy=1000, 
        kernel=GaussianKernel(1.0)
    )
)

println("Combined model: $(sum(real_combined.data .> 0)) unique interactions")

# ### Comparing All Three Model Types

# Side-by-side comparison of mass-action, trait-matching, and combined models:

real_mass = realize(metaweb, MassActionRealization(abundances; energy=1000))
real_traits_only = realize(
    metaweb, 
    TraitMatchingRealization(
        traits;
        energy=1000, 
        kernel=GaussianKernel(1.0)
    )
)

real_both = realize(
    metaweb, 
    TraitAbundanceRealization(
        abundances, 
        traits;
        energy=1000, 
        kernel=GaussianKernel(1.0)
    )
)

# fig-realization-modes
fig_compare = Figure(size=(900, 300))
ax_c1 = Axis(fig_compare[1,1], title="MassAction",
    xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax_c1, log10.(SIS.interactions(real_mass) .+ 1), colormap=:viridis)
ax_c2 = Axis(fig_compare[1,2], title="TraitMatching",
    xlabel="Species", ylabel="Species", aspect=1)
heatmap!(ax_c2, log10.(SIS.interactions(real_traits_only) .+ 1), colormap=:viridis)
ax_c3 = Axis(fig_compare[1,3], title="TraitAbundance",
    xlabel="Species", ylabel="Species", aspect=1)
hm_c = heatmap!(ax_c3, log10.(SIS.interactions(real_both) .+ 1), colormap=:viridis)
Colorbar(fig_compare[:, 4], hm_c, label="log10(events + 1)")
fig_compare #hide

# ### Bipartite Trait-Based Realization

# For bipartite networks, provide partitions trait matrices as a dictionary:

bipartite_traits = InteractionTraits(
    Dict(:plants => randn(15, 2), :pollinators => randn(20, 2)),
    bipartite_pool
)

bipartite_trait_realized = realize(
    bipartite_metaweb,
    TraitMatchingRealization(
        bipartite_traits;
        energy=1000, 
        kernel=GaussianKernel(1.0)
    )
)

bipartite_combined_realized = realize(
    bipartite_metaweb,
    TraitAbundanceRealization(
        bipartite_abund, 
        bipartite_traits;
        energy=1000, 
        kernel=GaussianKernel(1.0)
    )
)

println("\nBipartite TraitMatching: $(sum(bipartite_trait_realized.data .> 0)) unique")
println("Bipartite TraitAbundance: $(sum(bipartite_combined_realized.data .> 0)) unique")

# ## Simple Realization Models
#
# The package provides two simpler realization models to enable direct
# control over the sampling distribution.

# ### HomogeneousRealization
#
# `HomogeneousRealization` applies the **same distribution** to every possible interaction. This is the simplest realization model: provide a single `Distribution` object and every feasible interaction is sampled from it independently.

using Distributions

real_homog_low = realize(metaweb, HomogeneousRealization(Poisson(1.0)))
real_homog_high = realize(metaweb, HomogeneousRealization(Poisson(10.0)))

println("Homogeneous Poisson(1): $(sum(real_homog_low.data)) total events, $(sum(real_homog_low.data .> 0)) unique")
println("Homogeneous Poisson(10): $(sum(real_homog_high.data)) total events, $(sum(real_homog_high.data .> 0)) unique")

# Because the rate is the same for every pair, the number of realized interactions depends only on the number of feasible interactions and the distribution parameter:


# fig-homogenous
fig_homog = Figure(size=(700, 300))
ax_h1 = Axis(fig_homog[1,1], title="Poisson(1)", xlabel="Species", ylabel="Species", aspect=1)
hm_l = heatmap!(ax_h1, SIS.interactions(real_homog_low), colormap=:viridis)
Colorbar(fig_homog[:, 2], hm_l, label="Events")
ax_h2 = Axis(fig_homog[1,3], title="Poisson(10)", xlabel="Species", ylabel="Species", aspect=1)
hm_h = heatmap!(ax_h2, SIS.interactions(real_homog_high), colormap=:viridis)
Colorbar(fig_homog[:, 4], hm_h, label="Events")
fig_homog #hide


# ### CustomRateRealization
#
# `CustomRateRealization` lets you specify a **per-interaction rate matrix**. This is useful if you have externally estimated interaction rates (e.g. from empirical data or a separate model).

# Build a custom rate matrix — here we use a gradient as an example

n = numspecies(metaweb)
custom_rates = [SIS.interactions(metaweb)[i,j] ? 5.0 * exp(-abs(i - j) / 0.2n) : 0 for i in 1:n, j in 1:n]

real_custom = realize(metaweb, CustomRateRealization(custom_rates))

println("Custom rates (Poisson): $(sum(real_custom.data)) total events, $(sum(real_custom.data .> 0)) unique")

# fig-custom-realization
fig_custom = Figure(size=(800, 300))
ax_r = Axis(fig_custom[1,1], title="Rate matrix", xlabel="Species", ylabel="Species", aspect=1)
hm_r = heatmap!(ax_r, custom_rates, colormap=:viridis)
Colorbar(fig_custom[1,2], hm_r, label="Rate")
ax_c = Axis(fig_custom[1,3], title="Realized (Poisson)", xlabel="Species", ylabel="Species", aspect=1)
hm_c2 = heatmap!(ax_c, SIS.interactions(real_custom), colormap=:viridis)
Colorbar(fig_custom[1,4], hm_c2, label="Events")
fig_custom #hide

# You can pass any callable as the `distribution` keyword argument. The callable receives the per-interaction rate and must return a `Distribution`.For example, to double the rate:

real_scaled = realize(metaweb, CustomRateRealization(custom_rates; distribution=λ -> Poisson(2λ)))
println("Scaled rates: $(sum(real_scaled.data)) total events")

# Or use a completely different distribution family:

real_geom_custom = realize(metaweb,
    CustomRateRealization(custom_rates; distribution=λ -> Geometric(1 / (1 + λ))))
println("Geometric rates: $(sum(real_geom_custom.data)) total events")
