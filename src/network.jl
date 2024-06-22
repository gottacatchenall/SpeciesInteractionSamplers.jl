network(s::Scale) = s.network
adjacency(s::SpeciesInteractionNetwork) = s.edges.edges

struct Global{SIN<:SpeciesInteractionNetwork} <: Scale
    network::SIN
end
struct Spatial{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Matrix{Union{SIN,Nothing}}
end
Base.size(spat::Spatial) = size(network(spat))
Base.length(::Spatial) = 1
Base.eachindex(s::Spatial) = CartesianIndices(network(s))
Base.getindex(s::Spatial, ci::CartesianIndex) = network(s)[ci]
Base.getindex(s::Spatial, i::Integer) = network(s)[i]

struct Temporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Vector{Union{SIN,Nothing}}
end
Base.length(temp::Temporal) = length(network(temp))
Base.size(::Temporal) = (1, 1)
Base.eachindex(t::Temporal) = eachindex(network(t))
Base.getindex(t::Temporal, i::Integer) = network(t)[i]

struct Spatiotemporal{SIN<:SpeciesInteractionNetwork} <: Scale
    network::Array{Union{SIN,Nothing},3}
end
Base.size(st::Spatiotemporal) = size(network(st))[1:2]
Base.length(st::Spatiotemporal) = size(network(st), 3)


struct Network{ST<:State,SC<:Scale,SP<:SpeciesPool}
    species::SP
    scale::SC
    function Network{ST}(sp, net) where {ST}
        new{ST,typeof(net),typeof(sp)}(sp, net)
    end
end
Base.length(net::Network) = length(scale(net))
Base.eachindex(net::Network) = Base.eachindex(scale(net))
_format_string(net::Network{ST,SC}) where {ST,SC} = "{blue}$ST{/blue} {green}$SC{/green} {yellow}{bold}Network{/bold}{/yellow}"
Base.getindex(net::Network, x) = getindex(scale(net), x)


Base.show(io::IO, net::Network{ST,G}) where {ST,G<:Global} = begin
    tprint(
        io,
        Panel(_format_string(net))
    )
    if _interactive_repl()
        f = UnicodePlots.heatmap(
            adjacency(network(net)),
            xlabel="Species",
            ylabel="Species"
        )
        print(io, f)
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
@kwdef struct NicheModel{I<:Integer,F<:Real}
    species::I = 30
    connectance::F = 0.1
end

function generate(gen::NicheModel)
    S, C = gen.species, gen.connectance
    net = SpeciesInteractionNetworks.structuralmodel(SpeciesInteractionNetworks.NicheModel, S, C)
    net = mirror(net)
    sp = SpeciesPool(SpeciesInteractionNetworks.species(net))
    Network{Feasible}(sp, Global(net))
end


struct StochasticBlockModel
    node_ids
    mixing_matrix
    function StochasticBlockModel(; numspecies=20, numgroups=5)
        labels = [rand(1:numgroups) for _ in 1:numspecies]
        mixing = [rand(Beta(0.2, 0.8)) for _ in CartesianIndices((1:numgroups, 1:numgroups))]
        new(labels, mixing)
    end
end

function generate(sbm::StochasticBlockModel)
    y, M = sbm.node_ids, sbm.mixing_matrix
    adj_prob = [M[y[i], y[j]] for i in eachindex(y), j in eachindex(y)]
    adj = map(x -> rand() < x, adj_prob)
    speciespool = SpeciesPool([Symbol("node_$i") for i in 1:size(adj, 1)])
    net = SpeciesInteractionNetworks.simplify(SpeciesInteractionNetwork(
        SpeciesInteractionNetworks.Unipartite(speciespool.names),
        SpeciesInteractionNetworks.Binary(adj),
    ))
    net = mirror(net)

    Network{Feasible}(speciespool, Global(net))
end

# ===============================================================
#
# Helper methods
#
# ===============================================================
scale(net::Network) = net.scale
network(net::Network) = network(scale(net))
Base.size(net::Network) = size(network(net))

richness(net::N) where {N<:Network} = length(species(net))
species(net::N) where {N<:Network} = net.species
numspecies(net::N) where {N<:Network} = length(species(net))

function mirror(mw::SpeciesInteractionNetwork)
    symmetric_adj = (mw.edges.edges .+ mw.edges.edges') .> 0
    symmetric_adj .&= .!Matrix(LinearAlgebra.I, size(symmetric_adj)) # removes diagonal 
    return SpeciesInteractionNetwork(mw.nodes, SpeciesInteractionNetworks.Binary(symmetric_adj))
end

function aggregate(nets)
    M = nets.networks[1]
    for n in nets.networks
        M = M ∪ n
    end
    return M
end
