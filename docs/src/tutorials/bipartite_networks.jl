# # Working with Bipartite Networks

# This tutorial covers how to simulate sampling of bipartite interaction networks,
# such as plant-pollinator or host-parasite systems, where interactions only occur
# between species in different groups.

# ## What are Bipartite Networks?

# In a bipartite network, species are divided into two distinct groups (partitions),
# and interactions only occur between groups, not within them. Examples include:
#
# - **Plant-pollinator networks** - plants interact with their pollinators
# - **Host-parasite networks** - hosts interact with their parasites
# - **Plant-seed disperser networks** - plants interact with animals that disperse their seeds

# ## Setup

using SpeciesInteractionSamplers
const SIS = SpeciesInteractionSamplers
using CairoMakie

# ## Creating a Bipartite Species Pool

# Instead of `UnipartiteSpeciesPool`, we use `BipartiteSpeciesPool` with two partitions. Here we create a network with 15 plant species and 20 pollinator species:

pool = BipartiteSpeciesPool(15, 20; partition_names=[:plants, :pollinators])

# We can inspect the pool:

println("Total species: $(numspecies(pool))")
println("Plants: $(numspecies(pool, :plants))")
println("Pollinators: $(numspecies(pool, :pollinators))")

# ## Generating a Bipartite Feasible Network

# We can use `ErdosRenyi` to generate a random bipartite network with a given connectance (proportion of possible plant-pollinator pairs that interact):

metaweb = generate(ErdosRenyi(0.3), pool)

# Let's visualize the network structure:

# fig-metaweb
fig = Figure()
ax = Axis(fig[1,1],
    title="Plant-Pollinator Metaweb",
    xlabel="Pollinators",
    ylabel="Plants",
    aspect=DataAspect())
heatmap!(ax, SIS.interactions(metaweb)', colormap=[:white, :forestgreen])
fig #hide

# ## Generating Abundances for Each Partition

# When we generate abundances for a bipartite pool, abundances are created
# separately for each partition:

abundances = generate(LogNormalAbundance(σ=1.5), pool)

# ## Realizing Interactions

# The realization process works the same way, interaction rates depend on the abundances of both the plant and pollinator involved:

realized = realize(metaweb, MassActionRealization(abundances; energy=1000))

println("Feasible interactions: $(sum(metaweb.data))")
println("Realized interactions (unique): $(sum(realized.data .> 0))")
println("Total interaction events: $(sum(realized.data))")

# ## Detecting Interactions

# Detection also scales with the abundances of both interacting species:

detected = detect(realized, AbundanceScaledDetection(abundances))

println("Detected interactions (unique): $(sum(detected.data .> 0))")

# ## Visualizing the Sampling Pipeline
# Let's visualize how the network changes through the pipeline:

# fig-pipeline
fig2 = Figure(size=(900, 300))
ax1 = Axis(fig2[1,1], title="Feasible", xlabel="Pollinators", ylabel="Plants")
heatmap!(ax1, SIS.interactions(metaweb)', colormap=[:white, :black])
ax2 = Axis(fig2[1,2], title="Realized", xlabel="Pollinators", ylabel="Plants")
heatmap!(ax2, (SIS.interactions(realized) .> 0)', colormap=[:white, :steelblue])
ax3 = Axis(fig2[1,3], title="Detected", xlabel="Pollinators", ylabel="Plants")
heatmap!(ax3, (SIS.interactions(detected) .> 0)', colormap=[:white, :forestgreen])
fig2 #hide

# ## Adding Spatial Structure

# Bipartite networks can also have spatial structure. Let's add ranges for
# both plants and pollinators:

dims = (30, 30)
ranges = generate(AutocorrelatedRange(), pool, dims)

# Create a spatial context and filter to potential interactions:

context = SpatiotemporalContext(ranges)
potential = possibility(metaweb, context)

# Now the network has spatial dimensions - interactions can only occur
# where both species' ranges overlap:

println("Network dimensions: $(size(potential.data))")

# ## Sampling at a Specific Location

# We can examine which interactions are possible at a specific location:

x, y = 15, 15  # center of the landscape

# Check which species are present at this location
# (this would require accessing the range data for each partition)

# Realize and detect at this location with spatial structure:
realized_spatial = realize(potential, MassActionRealization(abundances; energy=500))
detected_spatial = detect(realized_spatial, AbundanceScaledDetection(abundances))

# Sum across all locations to get total detected per interaction:
total_per_interaction = sum(detected_spatial.data, dims=(3,4))
println("Unique interactions detected across landscape: $(sum(total_per_interaction .> 0))")

# ## Comparing Sampling Completeness

# Let's compare how completeness varies with effort for our bipartite network:

energies = [10^i for i in 2:0.5:6]
completeness = Float64[]
detected_count = Float64[]

total_feasible = sum(metaweb.data)

for e in energies
    real = realize(metaweb, MassActionRealization(abundances; energy=e))
    det = detect(real, AbundanceScaledDetection(abundances))
    push!(detected_count, sum(det.data))
    push!(completeness, sum(det.data .> 0) / total_feasible)
end

# fig-completeness
fig3 = Figure()
ax = Axis(fig3[1,1],
    xlabel="Total Interactions Seen",
    ylabel="Sampling Completeness",
    title="Plant-Pollinator Network Sampling",
    xscale=log10)
scatterlines!(ax, detected_count, completeness, markersize=12, color=:forestgreen)
hlines!(ax, [1.0], linestyle=:dash, color=:gray)
fig3 #hide

# ## Custom Species Names

# You can also create bipartite pools with custom species names:

plant_names = [:oak, :maple, :pine, :birch, :willow]
pollinator_names = [:bee, :butterfly, :moth, :fly, :beetle, :wasp]

custom_pool = BipartiteSpeciesPool(
    plant_names, pollinator_names;
    names=[:plants, :pollinators]
)

println(custom_pool)

