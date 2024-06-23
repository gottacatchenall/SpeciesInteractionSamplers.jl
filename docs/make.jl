push!(LOAD_PATH, "../src/")

using Documenter
using DocumenterCitations
using DocumenterMarkdown
using SpeciesInteractionSamplers

bibliography = CitationBibliography(joinpath(@__DIR__, "SIS.bib"))

makedocs(
    bibliography;
    sitename="SpeciesInteractionSamplers.jl",
    authors="Michael D. Catchen",
    modules=[SpeciesInteractionSamplers],
    format=Markdown(),)


deploydocs(;
    deps=Deps.pip("mkdocs", "pygments", "python-markdown-math", "mkdocs-material"),
    repo="github.com/gottacatchenall/SpeciesInteractionSamplers.jl.git",
    devbranch="main",
    make=() -> run(`mkdocs build`),
    target="site",
    push_preview=true,
)


