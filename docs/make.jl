using Documenter, DocumenterVitepress

using SpeciesInteractionSamplers

SpeciesInteractionSamplers.INTERACTIVE_REPL = false

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
        "Reference" => [
            #joinpath("reference", "internal.md"),
            joinpath("reference", "public.md")
        ]
    ],
    warnonly=true,
)

deploydocs(;
    repo="github.com/gottacatchenall/SpeciesInteractionSamplers.jl",
    push_preview=true,
)


