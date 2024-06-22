struct Abundance{A<:AbundanceTrait,S,T}
    species::SpeciesPool{S}
    abundance::Vector{T}
    function Abundance{RelativeAbundance}(sppool::SpeciesPool{S}, abd::Vector{T}) where {S,T}
        new{RelativeAbundance,S,T}(sppool, abd)
    end
end

Base.show(io::IO, abd::A) where {A<:Abundance} = begin
    x = abd.abundance |> sort |> reverse
    f = UnicodePlots.scatterplot(x)
    print(io, f)
end


Base.getindex(abd::Abundance{A,S,T}, sp::S) where {A,S,T} = begin
    idx = findfirst(isequal(sp), abd.species.names)
    return abd.abundance[idx]
end


struct TrophicScaling <: AbundanceGenerator end
struct NormalizedLogNormal <: AbundanceGenerator end

function generate(::NormalizedLogNormal, net::N) where {N<:Network}
    ra = rand(Truncated(LogNormal(0, 1), 0, Inf), numspecies(net))
    ra ./= sum(ra)
    return Abundance{RelativeAbundance}(species(net), ra)
end