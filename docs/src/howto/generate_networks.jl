# # How to Generate Networks

# This guide shows how to generate feasible interaction networks using different network generators.

using SpeciesInteractionSamplers
const SIS = SpeciesInteractionSamplers

# ## Available Network Generators

# The package provides several network generators:
#
# | Generator | Description | Best for |
# |-----------|-------------|----------|
# | `NicheModel` | Williams & Martinez niche model | Realistic food webs |
# | `ErdosRenyi` | Random graph with fixed connectance | Null models |

# ## Using NicheModel

# The Niche Model generates food webs with realistic structural properties. It assigns each species a value analogous to body size, and a range of niche-values/body sizes of species it eats

pool = UnipartiteSpeciesPool(40)

# The connectance parameter controls the proportion of possible interactions:

sparse_web = generate(NicheModel(0.05), pool)   # ~5% of possible interactions
dense_web = generate(NicheModel(0.25), pool)    # ~25% of possible interactions

println("Sparse web: $(sum(sparse_web.data)) interactions")
println("Dense web: $(sum(dense_web.data)) interactions")

# ## Using ErdosRenyi

# The Erdos-Renyi model creates random networks where each possible interaction exists independently with a fixed probability.

# For unipartite networks:

random_web = generate(ErdosRenyi(0.1), pool)
println("Random unipartite: $(sum(random_web.data)) interactions")

# For bipartite networks (e.g., plant-pollinator):

bipartite_pool = BipartiteSpeciesPool(20, 30; partition_names=[:plants, :pollinators])
bipartite_web = generate(ErdosRenyi(0.2), bipartite_pool)
println("Random bipartite: $(sum(bipartite_web.data)) interactions")

# ## Comparing Network Properties

# Different generators produce networks with different structural properties:

using CairoMakie

# fig-network-generators
fig = Figure(size=(600, 300))
ax1 = Axis(fig[1,1], title="Niche Model", aspect=1)
heatmap!(ax1, generate(NicheModel(0.15), pool) |> SIS.interactions, colormap=[:white, :black])
ax2 = Axis(fig[1,2], title="Erdos-Renyi", aspect=1)
heatmap!(ax2, generate(ErdosRenyi(0.15), pool) |> SIS.interactions, colormap=[:white, :black])
fig #hide