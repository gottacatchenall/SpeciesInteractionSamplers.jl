"""
    Metaweb{SC<:Scale,SP<:SpeciesPool}

A `Metaweb` represents a set of species and their interactions aggregated across space and/or time. 

A Metaweb is composed of a [`SpeciesPool`](@ref) and a set of interactions defined at a given [`Scale`](@ref).
"""
mutable struct Metaweb{SC<:Scale,SP<:SpeciesPool,SIN<:SpeciesInteractionNetwork,P}
    state::Type{<:State}   # this is not a parametric type to ensure it can be mutated without causing conversion errors
    species::SP
    scale::SC
    metaweb::SIN
    partiteness::P
    function Metaweb(st, sp, net, metaweb)
        new{typeof(net),typeof(sp),typeof(metaweb),typeof(metaweb.nodes)}(st, sp, net, metaweb, metaweb.nodes)
    end
end

Base.length(mw::Metaweb) = length(scale(mw))
Base.eachindex(mw::Metaweb) = eachindex(scale(mw))
Base.getindex(mw::Metaweb, x) = getindex(scale(mw), x)

#TODO: how to deal with spatial size vs Metaweb size?
Base.size(mw::Metaweb) = size(mw.metaweb)

resolution(mw::Metaweb) = resolution(scale(mw))

"""
    scale(mw::Metaweb)

Returns the input metaweb `mw` partitioned at the [`Scale`](@ref) it is defined at.
"""
scale(mw::Metaweb) = mw.scale

"""
    adjacency(mw::Metaweb)

Returns the adjacency network(s) associated with a Metaweb `net`.
"""
adjacency(mw::Metaweb{<:Global}) = Matrix(adjacency(scale(mw)))
adjacency(mw::Metaweb{SC}) where {SC} = Matrix.(adjacency(scale(mw)))

"""
    networks(mw::Metaweb)

Returns the local networks associated with the input metaweb `mw`.
"""
networks(mw::Metaweb) = networks(scale(mw))

"""
    richness(mw::M) where {M<:Metaweb}

Returns the number of species in the [`SpeciesPool`](@ref) associated with the input [`Metaweb`](@ref) `mw`. 
"""
richness(mw::M) where {M<:Metaweb} = length(species(mw))

"""
    species(mw::M) where {M<:Metaweb}

Returns the [`SpeciesPool`](@ref) that belongs to the input [`Metaweb`](@ref) `mw`.
"""
species(mw::M) where {M<:Metaweb} = mw.species

"""
    numspecies(mw::M) where {M<:Metaweb}

Returns the number of species in a [`Metaweb`](@ref) `mw`. 
"""
numspecies(mw::M) where {M<:Metaweb} = richness(mw)

# Add backslash before each square bracket
_add_escapes(str) = replace(str, Char(0x1B) => "\\e")

_format_string(net::Metaweb{SC}) where {SC} = "{blue}$(net.state){/blue} {green}$SC{/green} {yellow}{bold}Metaweb{/bold}{/yellow}"
Base.show(io::IO, net::Metaweb{G}) where {G<:Global} = begin
    if _interactive_repl()
        tprint(
            io,
            Panel(_format_string(net))
        )

        f = UnicodePlots.heatmap(
            adjacency(networks(net)),
            xlabel="Species",
            ylabel="Species"
        )
        print(io, f)
    else
        printstyled(io, "$(net.state) Global Metaweb", color=:blue)
    end

end


Base.show(io::IO, net::Metaweb{ST,SP}) where {ST,SP} = begin
    _, sz = sum(adjacency(net.metaweb)), resolution(net)
    unique_ints = sum(adjacency(net.metaweb) .> 0)
    details = 
    """
    - $unique_ints unique interactions, $(richness(net)) species  (density = $(unique_ints/(prod(sz))))
    - $sz spatial resolution
    - $(length(net)) timesteps
    """

    if _interactive_repl()
        str = _format_string(net)
        tprint(io, Panel(str, details))
    else
        println(io, "$ST $SP Metaweb")
        print(io, details)
    end
end

_label(::Type{Feasible}) = "Number feasible interactions across domain"
_label(::Type{Possible}) = "Number possible interactions across domain"
_label(::Type{Realizable}) = "Total rate across domain"
_label(::Type{Realized}) = "Number of realized interactions"
_label(::Type{Detected}) = "Number of detected interactions"
_label(::Type{Detectable}) = "Detection probability"

function plot(net::Metaweb{ST,<:Global}; args...) where {ST}
    f = Figure()
    ax = Axis(
        f[1, 1];
        args...
    )
    hm = CairoMakie.heatmap!(
        ax,
        adjacency(net)',
        colormap=[:white, :black]
    )
    Colorbar(f[1, 2], hm, label=_label(ST))
    return f
end


function plot(net::Metaweb{SC}; args...) where {SC<:Scale}
    f = Figure()
    ax = Axis(
        f[1, 1];
        args...
    )
    hm = CairoMakie.heatmap!(
        ax,
        Matrix(adjacency(net.metaweb))',
        colormap=[:white, :black]
    )
    Colorbar(f[1, 2], hm, label=_label(net.state))
    return f
end


# ==============================================================
#
# Generators
#
# ===============================================================

"""
    NicheModel

A [`MetawebGenerator`](@ref) that generates a food-web for a fixed number of `species` and an expected value of `connectance` (the proportion of possible edges that are feasible in the Metaweb). Proposed in @Williams2000SimRul.
"""
@kwdef struct NicheModel{I<:Integer,F<:Real} <: MetawebGenerator
    species::I = 30
    connectance::F = 0.1
end

"""
    generate(gen::NicheModel)

Generates a [`Feasible`](@ref) [`Metaweb`](@ref) using the niche model for food-web generation from Williams-Martinez (2000).
"""
function generate(gen::NicheModel{I,F}) where {I,F}
    S, C = gen.species, gen.connectance
    net = SpeciesInteractionNetworks.structuralmodel(SpeciesInteractionNetworks.NicheModel, S, C)

    net = SpeciesInteractionNetwork(
        net.nodes, 
        Quantitative{F}(net.edges.edges)
    )

    sp = SpeciesPool(SpeciesInteractionNetworks.species(net))
    Metaweb(Feasible, sp, Global(net), net)
end

"""
    StochasticBlockModel <: MetawebGenerator

A [`MetawebGenerator`](@ref) that generates a Metaweb based on assigning each node a group `node_ids`, and a matrix `mixing_matrix` which at each index `mixing_matrix[i,j]` describes the probability that an edge exists between a node in group `i` and a node in group `j`. 
"""
struct StochasticBlockModel{I,F} <: MetawebGenerator
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

Method for generating a [`Feasible`](@ref) [`Metaweb`](@ref) using a [`StochasticBlockModel`](@ref) generator.
"""
function generate(sbm::StochasticBlockModel)
    y, M = sbm.node_ids, sbm.mixing_matrix

    adj_prob = [M[y[i], y[j]] for i in eachindex(y), j in eachindex(y)]


    for I in CartesianIndices(adj_prob)
        if I[1] < I[2]
            adj[idx] = rand() < adj_prob[I]
        end
    end
    speciespool = SpeciesPool([Symbol("node_$i") for i in 1:size(adj, 1)])
    net = simplify(SpeciesInteractionNetwork(
        Unipartite(speciespool.names),
        Quantitative(adj),
    ))

    Metaweb(Feasible, speciespool, Global(net), net)
end

# ===============================================================
#
# Helper methods
#
# ===============================================================


"""
    mirror(mw::SpeciesInteractionNetwork)

Returns a symmetric (i.e. undirected) version of the input
`SpeciesInteractionNetwork` with no self loops (i.e. diagonal of the adjacency matrix is 0)
"""
function mirror(mw::SpeciesInteractionNetwork)
    symmetric_adj = (mw.edges.edges .+ mw.edges.edges') .> 0
    symmetric_adj .&= .!Matrix(LinearAlgebra.I, size(symmetric_adj)) # removes diagonal 
    return SpeciesInteractionNetwork(mw.nodes, Quantitative(symmetric_adj))
end

