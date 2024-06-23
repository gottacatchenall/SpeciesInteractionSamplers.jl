struct Range{T<:Number}
    range_map::Matrix{T}
end
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

@kwdef struct AutocorrelatedRange <: RangeGenerator
    autocorrelation = 0.85
    dims = (50, 50)
    threshold = Beta(10, 10)
end

function generate(ar::AutocorrelatedRange)
    H, sz, thres = ar.autocorrelation, ar.dims, rand(ar.threshold)

    range_mat = rand(DiamondSquare(H), sz)

    range_mat[findall(x -> x < thres, range_mat)] .= 0
    range_mat[findall(!iszero, range_mat)] .= 1
    return Range(range_mat)
end
