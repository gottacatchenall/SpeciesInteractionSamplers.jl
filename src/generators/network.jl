
# ====================================================================================
#
# ErdosRenyi 
#
# ====================================================================================

"""
    ErdosRenyi 
"""
struct ErdosRenyi <: NetworkGenerator
    connectance::Float64
end

"""
    generate(generator::ErdosRenyi; kwargs...)

"""
function generate(
    gen::ErdosRenyi,
    pool::UnipartiteSpeciesPool; 
)
    species_names = species(pool)
    metaweb = rand(numspecies(pool), numspecies(pool)) .< gen.connectance
    metadata = Dict{Symbol,Any}(
        :generator => gen,
    )
    feasible_network = NetworkLayer(
        Feasible(),
        pool,
        NamedArray(
            metaweb,
            names=(species_names, species_names), 
            dimnames=(:species, :species)
        ),
        metadata
    )
    return feasible_network
end

function generate(
    gen::ErdosRenyi,
    pool::BipartiteSpeciesPool; 
)
    
    part_names = getpartitionnames(pool)
    species_dims = [numspecies(pool, n) for n in part_names]
    metaweb = rand(species_dims...) .< gen.connectance
    return NetworkLayer(
        Feasible(),
        pool,
        DimArray(
            metaweb,
            getspeciesaxis(pool)
        ),
        Dict{Symbol,Any}()
    )
end


# ====================================================================================
#
# Niche Model 
#
# ====================================================================================


"""
    NicheModel 
"""
struct NicheModel <: NetworkGenerator
    connectance::Float64
end

"""
    generate(generator::NicheModel; kwargs...)

Generate a feasible metaweb using the Niche Model (Williams and Martinez 2000).
"""
function generate(
    gen::NicheModel,
    pool::UnipartiteSpeciesPool; 
)
    species_names = getspecies(pool)
    metaweb = SINs.structuralmodel(
        SINs.NicheModel, numspecies(pool), gen.connectance
    )
    metadata = Dict{Symbol,Any}(
        :generator => gen,
    )
    feasible_network = NetworkLayer(
        Feasible(),
        pool,
        DimArray(
            metaweb.edges.edges,
            (species=getspecies(pool), species2=getspecies(pool))
        ),
        metadata
    )
    return feasible_network
end


# ====================================================================================
#
# Stochastic Block Model 
#
# ====================================================================================

"""
    StochasticBlockModel

- Q here is how to structure fields to support uni and multipartite graphs
"""
struct StochasticBlockModel <: NetworkGenerator
    degree_sequence::Vector{Int}
end

# 
function generate(::StochasticBlockModel, pool::UnipartiteSpeciesPool)

end

