"""
    Network{ST<:State,SC<:Scale,SP<:SpeciesPool}

A `Network` represents a set of species and their interactions. 

A Network is composed of a [`SpeciesPool`](@ref) and a set of interactions defined at a given [`Scale`](@ref).
"""
struct Network{ST<:State,SC<:Scale,SP<:SpeciesPool}
    species::SP
    scale::SC
    function Network{ST}(sp, net) where {ST}
        new{ST,typeof(net),typeof(sp)}(sp, net)
    end
end

Base.length(net::Network) = length(scale(net))
Base.eachindex(net::Network) = eachindex(scale(net))
Base.getindex(net::Network, x) = getindex(scale(net), x)
Base.size(net::Network) = size(network(net))


"""
    scale(net::Network)

Returns the network partitioned at the [`Scale`](@ref) it is defined at.
"""
scale(net::Network) = net.scale

"""
    adjacency(net::Network)

Returns the adjacency network(s) associated with a Network `net`.
"""
adjacency(net::Network) = adjacency(scale(net))

"""
    network(net::Network)

One of the most confusing function calls I've ever written. 
"""
# TODO: Fix the internal scale type and associated getter to be more clear
network(net::Network) = network(scale(net))

"""
    richness(net::N) where {N<:Network}

Returns the number of species in the [`SpeciesPool`](@ref) associated with the input [`Network`](@ref) `net`. 
"""
richness(net::N) where {N<:Network} = length(species(net))

"""
    species(net::N) where {N<:Network}

Returns the [`SpeciesPool`](@ref) that belongs to the input [`Network`](@ref) `net`.
"""
species(net::N) where {N<:Network} = net.species

"""
    numspecies(net::N) where {N<:Network}

Returns the number of species in a [`Network`](@ref) `net`. 
"""
numspecies(net::N) where {N<:Network} = richness(net)

# Add backslash before each square bracket
_add_escapes(str) = ""

_format_string(::Network{ST,SC}) where {ST,SC} = "{blue}$ST{/blue} {green}$SC{/green} {yellow}{bold}Network{/bold}{/yellow}"
Base.show(io::IO, net::Network{ST,G}) where {ST,G<:Global} = begin
  if _interactive_repl()
        tprint(
            io,
            Panel(_format_string(net))
        )

        f = UnicodePlots.heatmap(
            adjacency(network(net)),
            xlabel="Species",
            ylabel="Species"
        )
        print(io, f)
    else
        print(io, Term.Style.apply_style(_format_string(net)))
    end
    
end

Base.show(io::IO, net::Network{ST,SP}) where {ST,SP} = begin
    str = _format_string(net)
    details = """
                - $(richness(net)) species 
                - $(size(scale(net))) spatial resolution
                - $(length(net)) timesteps
              """
    tprint(io, Panel(str, details))

end

# ==============================================================
#
# Generators
#
# ===============================================================

"""
    NicheModel

A [`NetworkGenerator`](@ref) that generates a food-web for a fixed number of `species` and an expected value of `connectance` (the proportion of possible edges that are feasible in the network). Proposed in @Williams2000SimRul.
"""
@kwdef struct NicheModel{I<:Integer,F<:Real} <: NetworkGenerator
    species::I = 30
    connectance::F = 0.1
end

"""
    generate(gen::NicheModel)

Generates a [`Feasible`](@ref) [`Network`](@ref) using the niche model for food-web generation from Williams-Martinez (2000).
"""
function generate(gen::NicheModel)
    S, C = gen.species, gen.connectance
    net = SpeciesInteractionNetworks.structuralmodel(SpeciesInteractionNetworks.NicheModel, S, C)
    net = mirror(net)
    sp = SpeciesPool(SpeciesInteractionNetworks.species(net))
    Network{Feasible}(sp, Global(net))
end

"""
    StochasticBlockModel <: NetworkGenerator

A [`NetworkGenerator`](@ref) that generates a network based on assigning each node a group `node_ids`, and a matrix `mixing_matrix` which at each index `mixing_matrix[i,j]` describes the probability that an edge exists between a node in group `i` and a node in group `j`. 
"""
struct StochasticBlockModel{I,F} <: NetworkGenerator
    node_ids::Vector{I}
    mixing_matrix::Matrix{F}
    function StochasticBlockModel(node_ids::Vector{I}, mixing_matrix::Matrix{F}) where {I<:Integer,F<:Real}
        new{I,F}(node_ids, mixing_matrix)
    end
end

"""
    StochasticBlockModel(; numspecies=SpeciesInteractionSamplers._DEFAULT_SPECIES_RICHNESS, numgroups=3)

Constructor for a [`StochasticBlockModel`](@ref) based on a set number of species and number of groups, where the mixing probabilities between groups `i` and `j` are drawn from `mixing_dist`
"""
function StochasticBlockModel(; numspecies=SpeciesInteractionSamplers._DEFAULT_SPECIES_RICHNESS, numgroups=3, mixing_dist=Beta(1, 5))
    labels = [rand(1:numgroups) for _ in 1:numspecies]
    mixing = [rand(mixing_dist) for _ in CartesianIndices((1:numgroups, 1:numgroups))]
    StochasticBlockModel(labels, mixing)
end

"""
    generate(sbm::StochasticBlockModel)

Method for generating a [`Feasible`](@ref) [`Network`](@ref) using a [`StochasticBlockModel`](@ref) generator.
"""
function generate(sbm::StochasticBlockModel)
    y, M = sbm.node_ids, sbm.mixing_matrix
    adj_prob = [M[y[i], y[j]] for i in eachindex(y), j in eachindex(y)]
    adj = map(x -> rand() < x, adj_prob)
    speciespool = SpeciesPool([Symbol("node_$i") for i in 1:size(adj, 1)])
    net = simplify(SpeciesInteractionNetwork(
        Unipartite(speciespool.names),
        Binary(adj),
    ))
    net = mirror(net)

    Network{Feasible}(speciespool, Global(net))
end

# ===============================================================
#
# Helper methods
#
# ===============================================================


"""
    mirror(mw::SpeciesInteractionNetwork)

Returns a symmetric (i.e. undirected) version of the input `SpeciesInteractionNetwork` (yes, the type from `SpeciesInteractionNetworks`, not our `Network` type ) with no self loops (i.e. diagonal of the adjacency matrix is 0)
"""
function mirror(mw::SpeciesInteractionNetwork)
    symmetric_adj = (mw.edges.edges .+ mw.edges.edges') .> 0
    symmetric_adj .&= .!Matrix(LinearAlgebra.I, size(symmetric_adj)) # removes diagonal 
    return SpeciesInteractionNetwork(mw.nodes, Binary(symmetric_adj))
end

function aggregate(nets)
end
