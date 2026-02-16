
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
    metaweb = rand(numspecies(pool), numspecies(pool)) .< gen.connectance
    metadata = Dict{Symbol,Any}(
        :generator => gen,
    )
    feasible_network = NetworkLayer(
        Feasible(),
        pool,
        DimArray(
            metaweb,
            (species=getspecies(pool), species2=getspecies(pool))
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


@testitem "ErdosRenyi generator" begin
    pool = UnipartiteSpeciesPool(10)

    # Unipartite 
    gen = ErdosRenyi(0.3)
    layer = generate(gen, pool)
    @test layer isa NetworkLayer{Feasible}
    @test numspecies(layer) == 10
    @test size(layer) == (10, 10)


    # Bipartite
    bpool = BipartiteSpeciesPool(5, 3; partition_names=[:prey, :predator])
    layer_bp = generate(ErdosRenyi(0.5), bpool)
    @test layer_bp isa NetworkLayer{Feasible}
    @test layer_bp.species isa BipartiteSpeciesPool
    @test numspecies(layer_bp) == 8
end

@testitem "NicheModel generator" begin
    pool = UnipartiteSpeciesPool(20)
    gen = NicheModel(0.15)
    layer = generate(gen, pool)

    @test layer isa NetworkLayer{Feasible}
    @test layer.state isa Feasible
    @test numspecies(layer) == 20
    @test size(layer) == (20, 20)
end

