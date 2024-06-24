"""
    Range{T<:Number}

A `Range` represents the binary occurrence of species across space using a raster.
"""
struct Range{T<:Number}
    range_map::Matrix{T}
end

"""
    occurrence(r::Range)

Returns the occurrence raster associated with a [`Range`](@ref)
"""
occurrence(r::Range) = r.range_map

Base.size(r::Range) = size(r.range_map)
Base.show(io::IO, r::R) where {R<:Range} = begin
    tprint(io, "{green}$R with dimensions $(size(r.range_map)){/green}\n")
    if _interactive_repl()
        p = UnicodePlots.heatmap(
            r.range_map,
            xlabel="x",
            ylabel="y"
        )
        print(io, p)
    end
end

# ========================================
#
# Generators
#
# ========================================
"""
    AutocorrelatedRange <: RangeGenerator

A [`RangeGenerator`](@ref) that uses NeutralLandscapes.jl's `DiamondSquare` landscape generator to create autocorrelated rasters with autocorrelatation parameter ranging between 0 and 1, where increasing values mean increasing autocorrelated. The autocorrelated raster is thresholded where all values in the raster above the `threshold` are present, and all values below are absent. The value of `threshold` is either provided as a scalar, or drawn from a distribution. 
"""
@kwdef struct AutocorrelatedRange <: RangeGenerator
    autocorrelation = 0.85
    dims = (50, 50)
    threshold = Beta(10, 10)
end

"""
    generate(ar::AutocorrelatedRange)

Generates a [`Range`](@ref) using the [`AutocorrelatedRange`](@ref) [`RangeGenerator`](@ref).
"""
function generate(ar::AutocorrelatedRange)
    H, sz, thres = ar.autocorrelation, ar.dims, rand(ar.threshold)

    range_mat = rand(DiamondSquare(H), sz)

    range_mat[findall(x -> x < thres, range_mat)] .= 0
    range_mat[findall(!iszero, range_mat)] .= 1
    return Range(range_mat)
end
