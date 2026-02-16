# # How to Configure Detection Models

# This guide shows how to configure different detection models that control how likely it is that a realized interaction gets observed.

using SpeciesInteractionSamplers
using CairoMakie
using NeutralLandscapes

# ## Detection in the Pipeline

# The detection stage transforms Realized → Detected. Each realized interaction has an independent, identically distributed probability of being detected, and the number of detections follows a binomial distribution.

# ## Setup

pool = UnipartiteSpeciesPool(30)
metaweb = generate(NicheModel(0.15), pool)
abundances = generate(LogNormalAbundance(), pool)
realized = realize(metaweb, MassActionRealization(abundances; energy=1000))

println("Realized interactions: $(sum(realized.data))")

# ## Available Detection Models

# The package provides three detection models:
#
# | Model | Description | Use case |
# |-------|-------------|----------|
# | `PerfectDetection` | All realized interactions detected | Ideal scenario |
# | `BinomialDetection` | Constant detection probability (but can be adjusted to vary in space/time) | Simple imperfect detection |
# | `AbundanceScaledDetection` | Detection scales with abundance | Realistic sampling |

# ## Using PerfectDetection

# Every realized interaction is detected:

detected_perfect = detect(realized, PerfectDetection())
println("Perfect detection: $(sum(detected_perfect.data)) detections")

# ## Using BinomialDetection

# Each realized interaction is detected with a fixed probability:

# Low detection probability:
detected_low = detect(realized, BinomialDetection(prob=0.2))
println("Low detection (p=0.2): $(sum(detected_low.data)) detections")

# High detection probability:
detected_high = detect(realized, BinomialDetection(prob=0.8))
println("High detection (p=0.8): $(sum(detected_high.data)) detections")

# ### Spatially Variable Detection
#
# In real sampling, detection probability often varies across space as some sites are easier to survey than others (e.g. sampling birds based on calls in a quiet vs noisy environment). To have unique site-level detection probabilities, pass `BinomialDetection` a `DimArray` whose dimensions match the spatial/temporal domain.

using SpeciesInteractionSamplers: DimArray, Dim, dims

dims_xy = (30, 30)
ranges = generate(AutocorrelatedRange(), pool, dims_xy)
context = SpatiotemporalContext(ranges)
potential = possibility(metaweb, context)
realized_spatial = realize(potential, MassActionRealization(abundances; energy=5000))

# Create a spatial detection-probability map using NeutralLandscapes.jl

spatial_probs = DimArray(
    rand(DiamondSquare(0.8), dims_xy),
    (Dim{:x}(1:30), Dim{:y}(1:30))
)

detected_spatial = detect(realized_spatial, BinomialDetection(spatial_probs))
total_per_site = dropdims(sum(detected_spatial.data, dims=(:species, :species2)), dims=(:species, :species2));

# fig-spatial-detection
fig_sp = Figure(size=(900, 350))
ax1 = Axis(fig_sp[1, 1], title="Detection probability",
    xlabel="x", ylabel="y", aspect=1)
hm1 = heatmap!(ax1, parent(spatial_probs), colormap=:viridis)
Colorbar(fig_sp[1, 2], hm1, label="p")
ax2 = Axis(
    fig_sp[1, 3], 
    title="Total detections per site",
    xlabel="x", 
    ylabel="y",
    aspect=1
)
hm2 = heatmap!(ax2, parent(total_per_site), colormap=:inferno)
Colorbar(fig_sp[1, 4], hm2, label="Detections")
fig_sp #hide 

# ### Species-Level Variable Detection
#
# Detection probability can also vary by species pair. For example, some interactions are intrinsically easier to observe (larger species, not avoidant of people). To enable this, pass a `DimArray` with the same species dimensions as the interaction network to `BinomialDetection`.

species_names = getspecies(pool)
n = length(species_names)

# Simulate random pairwise detection probability:
pair_probs = DimArray(
    rand(size(metaweb)...) .* SpeciesInteractionSamplers.interactions(metaweb),
    (Dim{:species}(species_names), Dim{:species2}(species_names))
)

detected_species = detect(realized_spatial, BinomialDetection(pair_probs))
total_per_pair = dropdims(sum(detected_species.data, dims=(:x, :y)), dims=(:x, :y));

# fig-pairwise-detection
fig_pair = Figure(size=(700, 350))
ax_p1 = Axis(fig_pair[1, 1], title="Pairwise detection probability",
    xlabel="Species", ylabel="Species", aspect=1)
hm_p1 = heatmap!(ax_p1, parent(pair_probs), colormap=:viridis, colorrange=(0, 1))
Colorbar(fig_pair[1, 2], hm_p1, label="p")
ax_p2 = Axis(fig_pair[1, 3], title="Total detections per pair",
    xlabel="Species", ylabel="Species", aspect=1)
hm_p2 = heatmap!(ax_p2, parent(total_per_pair), colormap=:inferno)
Colorbar(fig_pair[1, 4], hm_p2, label="Detections")
fig_pair #hide  

# ### Full Species × Space Variability
#
# For maximum flexibility, you can pass a `DimArray` whose shape matches the realized network exactly (species × species × domain). This allows every unique realized interaction at every location to have its own detection probability.

full_probs = DimArray(
    rand(n,n,dims_xy...),
    dims(realized_spatial.data)
)

detected_full = detect(realized_spatial, BinomialDetection(full_probs))
println("Full variable detection: $(sum(detected_full.data)) detections")

# ## Using AbundanceScaledDetection

# Detection probability depends on species abundances, and interactions involving abundant species are easier to detect.

detected_scaled = detect(realized, AbundanceScaledDetection(abundances))

# This model has two components:
# 1. **Scaling mode**: How individual species detectability relates to abundance
# 2. **Combination mode**: How to combine detectabilities of two species

# ## Detectability Scaling Modes

# **ExponentialDetectability** (default): Detectability increases exponentially with abundance. The coefficient controls how quickly.

# Weak scaling (rare species still fairly detectable):
weak_scaling = AbundanceScaledDetection(
    abundances;
    scaling_mode=ExponentialDetectability(2.0)
)

# Strong scaling (rare species very hard to detect):
strong_scaling = AbundanceScaledDetection(
    abundances;
    scaling_mode=ExponentialDetectability(20.0)
)

# Visualize the scaling:

# fig-scaling
fig = Figure(size=(600, 400))
x = 0:0.01:1
ax = Axis(fig[1,1],
    xlabel="Relative Abundance",
    ylabel="Detection Probability",
    title="Detectability Scaling Functions")
lines!(ax, x, ExponentialDetectability(2.0).(x), label="α=2 (weak)", linewidth=2)
lines!(ax, x, ExponentialDetectability(5.0).(x), label="α=5 (default)", linewidth=2)
lines!(ax, x, ExponentialDetectability(20.0).(x), label="α=20 (strong)", linewidth=2)
axislegend(ax, position=:rb)
fig #hide

# **LinearDetectability**: Simple linear scaling

linear_det = AbundanceScaledDetection(
    abundances;
    scaling_mode=LinearDetectablity(1.0)
)

# ## Combination Modes

# When two species interact, how do we combine their individual detectabilities?

# - **DetectabilityProduct** (default): Multiply both detectabilities
# - **DetectabilityMin**: Take the minimum
# - **DetectabilityMax**: Take the maximum
# - **DetectabilityMean**: Average of both

det_product = detect(realized, AbundanceScaledDetection(abundances;
    combination_mode=DetectabilityProduct()))

det_min = detect(realized, AbundanceScaledDetection(abundances;
    combination_mode=DetectabilityMin()))

det_max = detect(realized, AbundanceScaledDetection(abundances;
    combination_mode=DetectabilityMax()))

det_mean = detect(realized, AbundanceScaledDetection(abundances;
    combination_mode=DetectabilityMean()))

println("Product: $(sum(det_product.data .> 0)) unique interactions detected")
println("Min: $(sum(det_min.data .> 0)) unique interactions detected")
println("Max: $(sum(det_max.data .> 0)) unique interactions detected")
println("Mean: $(sum(det_mean.data .> 0)) unique interactions detected")

# ## Visualizing Combination Modes

# Let's look at interaction detection probability for different abundance combinations under product and mean modes:

abundances_i = 0:0.02:1
abundances_j = 0:0.02:1
α = 2.0

# fig-combination-modes
fig2 = Figure(size=(800, 400))
ax1 = Axis(fig2[1,1], title="Product", xlabel="Species i abundance", ylabel="Species j abundance")
prob_product = [DetectabilityProduct()(ExponentialDetectability(α)(ai), ExponentialDetectability(α)(aj))
    for ai in abundances_i, aj in abundances_j]
heatmap!(ax1, abundances_i, abundances_j, prob_product, colorrange=(0,1))
ax2 = Axis(fig2[1,2], title="Mean", xlabel="Species i abundance", ylabel="Species j abundance")
prob_mean = [DetectabilityMean()(ExponentialDetectability(α)(ai), ExponentialDetectability(α)(aj))
    for ai in abundances_i, aj in abundances_j]
hm = heatmap!(ax2, abundances_i, abundances_j, prob_mean, colorrange=(0,1))
Colorbar(fig2[1,3], hm, label="Detection Probability")
fig2 #hide

# ## Effect on Sampling Completeness

# Compare how detection models affect completeness at different effort levels:

energies = [50, 100, 500, 1000, 5000]
n_feasible = sum(metaweb.data)

completeness_perfect = Float64[]
completeness_binomial = Float64[]
completeness_scaled = Float64[]
total_realized = []

for e in energies
    real = realize(metaweb, MassActionRealization(abundances; energy=e))

    d_perfect = detect(real, PerfectDetection())
    d_binomial = detect(real, BinomialDetection(prob=0.5))
    d_scaled = detect(real, AbundanceScaledDetection(abundances))

    push!(total_realized, sum(real.data))
    push!(completeness_perfect, sum(d_perfect.data .> 0) / n_feasible)
    push!(completeness_binomial, sum(d_binomial.data .> 0) / n_feasible)
    push!(completeness_scaled, sum(d_scaled.data .> 0) / n_feasible)
end

# fig-completeness
fig3 = Figure()
ax = Axis(fig3[1,1],
    xlabel="Total Detected Interactions",
    ylabel="Sampling Completeness",
    xscale=log10)
scatterlines!(ax, total_realized, completeness_perfect, label="Perfect", color=:seagreen4)
scatterlines!(ax, total_realized, completeness_binomial, label="Binomial (p=0.5)", color=:steelblue)
scatterlines!(ax, total_realized, completeness_scaled, label="Abundance-scaled", color=:coral)
axislegend(ax, position=:lt)
fig3 #hide

# ## Detection for Bipartite Networks

# Detection models work the same way for bipartite networks:

bipartite_pool = BipartiteSpeciesPool(15, 20; partition_names=[:plants, :pollinators])
bipartite_metaweb = generate(ErdosRenyi(0.2), bipartite_pool)
bipartite_abund = generate(LogNormalAbundance(), bipartite_pool)

bipartite_realized = realize(bipartite_metaweb,
    MassActionRealization(bipartite_abund; energy=500))

bipartite_detected = detect(bipartite_realized,
    AbundanceScaledDetection(bipartite_abund))

println("Bipartite detected: $(sum(bipartite_detected.data .> 0)) interactions")