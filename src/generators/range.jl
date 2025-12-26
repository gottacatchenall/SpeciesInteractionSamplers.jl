"""
    generate(
        range_generator::RangeGenerator, 
        num_species, 
        dims;
        names = nothing
    )

Initial dispatch for generating ranges. 
"""
function generate(
    range_generator::RangeGenerator,
    pool::UnipartiteSpeciesPool,
    dims;
    dim_names = (:x, :y),
    kwargs...
)

    ranges = [generate(range_generator, dims; kwargs...) for i in 1:numspecies(pool)]
    
    axis = merge(getspeciesaxis(pool), (x=1:dims[1], y=1:dims[2]))

    Ranges(
        UnipartiteTrait(
            DimArray(
            stack(
                ranges,
                dims=1
            ),
            axis
        )
    ))
end

function generate(
    range_generator::RangeGenerator,
    pool::MultipartiteSpeciesPool,
    dims;
    kwargs...
)
  
    ranges = Dict{Symbol,DimArray}()
    for (partition_name, partition) in getpartitions(pool)
        axis = merge(getspeciesaxis(partition, partition_name), (x=1:dims[1], y=1:dims[2]))
        ranges[partition_name] = DimArray(stack([generate(range_generator, dims; kwargs...) for i in 1:numspecies(partition)], dims=1), axis)
    end
    return Ranges(PartitionedTrait(ranges))
end



# ====================================================================================
#
# AutocorrelatedRange 
#
# ====================================================================================

"""
    AutocorrelatedRange <: RangeGenerator

A [`RangeGenerator`](@ref) that uses NeutralLandscapes.jl's `DiamondSquare` landscape generator to create autocorrelated rasters with autocorrelatation parameter ranging between 0 and 1, where increasing values mean increasing autocorrelated. The autocorrelated raster is thresholded where all values in the raster above the `threshold` are present, and all values below are absent. The value of `threshold` is either provided as a scalar, or drawn from a distribution. 
"""
@kwdef struct AutocorrelatedRange <: RangeGenerator
    autocorrelation = 0.85
    prevalence = Beta(10, 10)
end

"""
    generate(ar::AutocorrelatedRange)

Generates [`Ranges`](@ref) using the [`AutocorrelatedRange`](@ref) [`RangeGenerator`](@ref).
"""
function generate(ar::AutocorrelatedRange, dims)
    H = ar.autocorrelation
    threshold = ar.prevalence isa Number ? ar.prevalence : rand(ar.prevalence)

    range_mat = rand(DiamondSquare(H), dims)

    range_mat[findall(x -> x < threshold, range_mat)] .= 0
    range_mat[findall(!iszero, range_mat)] .= 1
    return Bool.(range_mat)
end

