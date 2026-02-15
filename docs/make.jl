using Documenter, DocumenterVitepress

using SpeciesInteractionSamplers

makedocs(;
    modules=[SpeciesInteractionSamplers],
    authors="Michael D. Catchen",
    repo="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl/blob/{commit}{path}#{line}",
    sitename="SpeciesInteractionSamplers.jl",
    format=DocumenterVitepress.MarkdownVitepress(
        repo="https://github.com/gottacatchenall/SpeciesInteractionSamplers.jl",
        devurl="dev",
    ),
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "Getting Started" => joinpath("tutorials", "getting_started.md"),
            "Bipartite Networks" => joinpath("tutorials", "bipartite_networks.md"),
            "Spatiotemporal Sampling" => joinpath("tutorials", "spatiotemporal_sampling.md"),
        ],
        "How-To Guides" => [
            "Generating Networks" => joinpath("howto", "generate_networks.md"),
            "Spatial Networks" => joinpath("howto", "ranges.md"),
            "Temporal Networks" => joinpath("howto", "phenologies.md"),
            "Configuring Abundances" => joinpath("howto", "configure_abundance.md"),
            "Realization Models" => joinpath("howto", "realization_models.md"),
            "Detection Models" => joinpath("howto", "detection_models.md"),
        ],
        "Reference" => [
            "Public API" => joinpath("reference", "public.md"),
            "Internal API" => joinpath("reference", "internal.md"),
        ],
    ],
    warnonly=true,
)

DocumenterVitepress.deploydocs(;
    repo="github.com/gottacatchenall/SpeciesInteractionSamplers.jl",
    push_preview=true,
)