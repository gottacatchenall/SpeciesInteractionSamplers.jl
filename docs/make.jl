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
        ],
        "Case Studies" => [
            "Abundance Combination Mode" => joinpath("tutorials", "abundancemode.md"),
        ],
        "Reference" => [
            #joinpath("reference", "internal.md"),
            joinpath("reference", "public.md")
        ],
    ],
    warnonly=true,
)

DocumenterVitepress.deploydocs(;
    repo="github.com/gottacatchenall/SpeciesInteractionSamplers.jl",
    push_preview=true,
)


