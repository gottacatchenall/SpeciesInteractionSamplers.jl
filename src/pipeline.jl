"""
    Pipeline operator for chaining transformations.
"""
Base.:(|>)(layer::NetworkLayer{Feasible}, context::SpatiotemporalContext) =
    possibility(layer, context)

Base.:(|>)(layer::NetworkLayer{Potential}, model::RealizationModel) =
    realize(layer, model)

Base.:(|>)(layer::NetworkLayer{Feasible}, model::RealizationModel) =
    realize(layer, model)

Base.:(|>)(layer::NetworkLayer{Realized}, model::DetectabilityModel) =
    detect(layer, model)


"""
    sample_network(; generator, context, realization, detection, kwargs...)

Complete pipeline from metaweb to detected network.
"""    
function sample_network(;
    species = UnipartiteSpeciesPool(10),
    generator::NetworkGenerator,
    context::SpatiotemporalContext,
    realization::RealizationModel,
    detection::DetectabilityModel,
    return_all_stages::Bool=false
)
    feasible = generate(generator, species)
    potential = possibility(feasible, context)
    realized = realize(potential, realization)
    detected = detect(realized, detection)
    
    if return_all_stages
        return (
            feasible=feasible,
            potential=potential,
            realized=realized,
            detected=detected
        )
    else
        return detected
    end
end

@testitem "Pipeline works with unipartite" begin
    pool = UnipartiteSpeciesPool(5)
    feasible = generate(ErdosRenyi(0.5), pool)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    context = SpatiotemporalContext(ranges)
    abundance = generate(LogNormalAbundance(), pool)

    # Feasible |> Context yields Potential
    potential = feasible |> context
    @test potential isa NetworkLayer{Potential}

    # Potential |> Realization yields Realized
    realized = potential |> MassActionRealization(abundance; energy=10.0)
    @test realized isa NetworkLayer{Realized}

    # Realized |> Detection yields Detected
    detected = realized |> BinomialDetection(prob=0.8)
    @test detected isa NetworkLayer{Detected}
end

@testitem "Pipeline works with bipartite" begin
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:prey, :pred])
    feasible = generate(ErdosRenyi(0.5), pool)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    context = SpatiotemporalContext(ranges)
    abundance = generate(LogNormalAbundance(), pool)

    potential = feasible |> context
    @test potential isa NetworkLayer{Potential}

    realized = potential |> MassActionRealization(abundance; energy=10.0)
    @test realized isa NetworkLayer{Realized}

    detected = realized |> PerfectDetection()
    @test detected isa NetworkLayer{Detected}
end

@testitem "sample_network works with unipartite" begin
    pool = UnipartiteSpeciesPool(6)
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    phens = generate(UniformPhenology(), pool, 10)
    abundance = generate(LogNormalAbundance(), pool)

    # Default: returns only detected
    detected = sample_network(
        species=pool,
        generator=ErdosRenyi(0.3),
        context=SpatiotemporalContext(ranges, phens),
        realization=MassActionRealization(abundance; energy=10.0),
        detection=BinomialDetection(prob=0.5)
    )
    @test detected isa NetworkLayer{Detected}

    # Return all stages option
    result = sample_network(
        species=pool,
        generator=ErdosRenyi(0.3),
        context=SpatiotemporalContext(ranges, phens),
        realization=MassActionRealization(abundance; energy=10.0),
        detection=BinomialDetection(prob=0.5),
        return_all_stages=true
    )
    @test result isa NamedTuple
    @test haskey(result, :feasible)
    @test haskey(result, :potential)
    @test haskey(result, :realized)
    @test haskey(result, :detected)
    @test result.feasible isa NetworkLayer{Feasible}
    @test result.potential isa NetworkLayer{Potential}
    @test result.realized isa NetworkLayer{Realized}
    @test result.detected isa NetworkLayer{Detected}
end

@testitem "sample_network works with bipartite" begin
    pool = BipartiteSpeciesPool(4, 3; partition_names=[:plants, :pollinators])
    ranges = generate(AutocorrelatedRange(), pool, (8, 8))
    abundance = generate(LogNormalAbundance(), pool)

    detected = sample_network(
        species=pool,
        generator=ErdosRenyi(0.5),
        context=SpatiotemporalContext(ranges),
        realization=MassActionRealization(abundance; energy=5.0),
        detection=PerfectDetection()
    )
    @test detected isa NetworkLayer{Detected}
    @test detected.species isa BipartiteSpeciesPool
end

