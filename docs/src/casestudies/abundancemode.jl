# # Abundance Realization Modes

using SpeciesInteractionSamplers
using DataFrames
using Statistics
using CairoMakie

pool = UnipartiteSpeciesPool(40)
metaweb = generate(NicheModel(0.1), pool)
abundances = generate(LogNormalAbundance(), pool)

Es = 0:200:25000
num_reps = 250

results = DataFrame(
    total_detected = [],
    completeness = [],
    mode = [],
    energy = []
)

realization_modes = [AbundanceMin(), AbundanceMean(), AbundanceMax(), AbundanceProduct()]
detection_modes = [DetectabilityMin(), DetectabilityMean(), DetectabilityMax(), DetectabilityProduct()]

for r in 1:num_reps
    for (i,mode) in enumerate(realization_modes)
        for energy in Es 
            realized = realize(metaweb, MassActionRealization(abundances; energy=energy, combination_mode=mode))
            detected = detect(realized, AbundanceScaledDetection(abundances; combination_mode=DetectabilityMean()))
            unique_detected = sum(detected.data .> 0)
            completeness =  unique_detected / sum(metaweb.data)
            total_detected = sum(detected.data)
            push!(results, (total_detected, completeness, mode, energy))
        end 
    end 
end 

function bin_and_compute_stats(x, y, bin_width)
    bin_indices = floor.(Int, x ./ bin_width)
    bins = Dict{Int, Vector{Float64}}()
    for (i, bin_idx) in enumerate(bin_indices)
        if !haskey(bins, bin_idx)
            bins[bin_idx] = Float64[]
        end
        push!(bins[bin_idx], y[i])
    end
    x = Float64[(bin_idx + 0.5) * bin_width for (bin_idx, y_values) in sort(bins)]
    y_mean = Float64[mean(y_values) for (bin_idx, y_values) in sort(bins)]
    y_std = Float64[std(y_values) for (bin_idx, y_values) in sort(bins)]
    return x, y_mean, y_std
end



bin_width = 20

cols = [:dodgerblue, :mediumpurple4, :seagreen, :orange]


f = Figure()
ax = Axis(
    f[1,1], 
    aspect=1,
    yticks=0:0.2:1,
    xlabel = "Total Detected Interactions",
    xticks = (1:0.5:3.5, [L"10^1", L"10^{1.5}", L"10^2", L"10^{2.5}", L"10^3", L"10^{3.5}"]),
    ylabel = "Proportion of Feasible Interactions Seen",
    xticklabelsize=19
)
xlims!(ax, 1, 3.5)
ylims!(ax, 0, 1)
for (i, mode) in enumerate(realization_modes)
    df = filter(x->x.mode == mode, results)
    x, μ, σ = bin_and_compute_stats(df.total_detected, df.completeness, bin_width)
    band!(ax, log10.(x), μ .- σ, μ .+ σ, color=(cols[i], 0.2))
    lines!(ax, log10.(x), μ, color=cols[i])
end
axislegend(
        ax,
        [MarkerElement(color = c, marker = :rect, markersize=23) for c in cols],
        ["Minimum Abundance", "Mean Abundance", "Maximum Abundance", "Product of Abundance"],
        "Realization Mode",
        position=:lt
    )

f

