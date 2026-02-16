
_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,<:Phenologies}
) =  @d metaweb.data .* parent(context.ranges) .* parent(context.phenologies)

_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,Missing}
) =  @d metaweb.data .* parent(context.ranges)
_get_possibility(
    metaweb::NetworkLayer{Feasible,UnipartiteSpeciesPool},
    context::SpatiotemporalContext{Missing,<:Phenologies}
) =  @d metaweb.data .* parent(context.phenologies)

_get_possibility(
    metaweb::NetworkLayer{Feasible,BipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,<:Phenologies}
) = broadcast_dims(*, metaweb.data, values(context.ranges)..., values(context.phenologies)...)

_get_possibility(
    metaweb::NetworkLayer{Feasible,BipartiteSpeciesPool},
    context::SpatiotemporalContext{<:Ranges,Missing}
) = broadcast_dims(*, metaweb.data, values(context.ranges)...)

_get_possibility(
    metaweb::NetworkLayer{Feasible,BipartiteSpeciesPool},
    context::SpatiotemporalContext{Missing,<:Phenologies}
) = broadcast_dims(*, metaweb.data, values(context.phenologies)...)


"""
    possibility(
        layer::NetworkLayer{Feasible}, 
        context::SpatiotemporalContext
    )

Transforms Feasible → Potential by applying co-occurrence filter.
"""
function possibility(
    metaweb::NetworkLayer{Feasible}, 
    context::SpatiotemporalContext
) 
    possible = _get_possibility(metaweb, context)
    NetworkLayer(
        Potential(),
        getspecies(metaweb),
        possible, 
        metaweb.metadata
    )
end 

"""
    possibility(
        layer::NetworkLayer{Feasible}, 
        context::SpatiotemporalContext
    )

Transforms Feasible → Potential by applying co-occurrence filter.
"""
function possibility(
    metaweb::NetworkLayer{Feasible},
    context::Missing
)
    NetworkLayer(
        Potential(),
        getspecies(metaweb),
        metaweb.data,
        metaweb.metadata
    )
end

# =================================================================================
#
# Tests
#
# =================================================================================

@testitem "Possibility filter - unipartite spatial" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    ctx = SpatiotemporalContext(ranges)

    potential = possibility(layer, ctx)
    @test potential isa NetworkLayer{Potential}
    @test potential.species === pool
end

@testitem "Possibility filter - unipartite temporal" begin
    pool = UnipartiteSpeciesPool(5)
    layer = generate(ErdosRenyi(1.0), pool)
    phens = generate(UniformPhenology(), pool, 10)
    ctx = SpatiotemporalContext(phens)

    potential = possibility(layer, ctx)
    @test potential isa NetworkLayer{Potential}
end

@testitem "Possibility filter - unipartite spatiotemporal" begin
    pool = UnipartiteSpeciesPool(4)
    layer = generate(ErdosRenyi(1.0), pool)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    phens = generate(UniformPhenology(), pool, 10)
    ctx = SpatiotemporalContext(ranges, phens)

    potential = possibility(layer, ctx)
    @test potential isa NetworkLayer{Potential}
end

@testitem "Possibility filter - bipartite spatial" begin
    pool = BipartiteSpeciesPool(3, 2; partition_names=[:A, :B])
    layer = generate(ErdosRenyi(1.0), pool)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    ctx = SpatiotemporalContext(ranges)

    potential = possibility(layer, ctx)
    @test potential isa NetworkLayer{Potential}
    @test potential.species isa BipartiteSpeciesPool
end

@testitem "Possibility filter - bipartite temporal" begin
    pool = BipartiteSpeciesPool(3, 2; partition_names=[:A, :B])
    layer = generate(ErdosRenyi(1.0), pool)
    phens = generate(UniformPhenology(), pool, 10)
    ctx = SpatiotemporalContext(phens)

    potential = possibility(layer, ctx)
    @test potential isa NetworkLayer{Potential}
end
