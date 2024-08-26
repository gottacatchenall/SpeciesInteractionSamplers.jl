
struct Static end

@kwdef struct SpeciesInteractionSampler{R,P}
    _feasibility_model = NicheModel()
    _range_model::R = Static()
    _phenology_model::P = Static()
    _abundance_model = NormalizedLogNormal()
    _realization_model = NeutrallyForbiddenLinks()
    _detection_model = RelativeAbundanceScaled()
end

struct Sample{L,D}
    λ::L
  #  abd::A
  #  δ::D
  #  γ::G
  #  θ::T
  #  ζ::Z
    detected::D
end
Base.show(io::IO, s::Sample) = tprint(io, "Sample with FNR = $(falsenegativerate(s))")

struct SampleSet{S<:Sample}
    set::Vector{S}
end
Base.length(s::SampleSet) = length(s.set)
falsenegativerate(s::SampleSet) = mean(falsenegativerate.(s.set))
Base.show(io::IO, set::SampleSet) = tprint(io, "$(length(set)) samples with FNR = $(falsenegativerate(set))")


function sample(sampler::SpeciesInteractionSampler, n::Integer)
    SampleSet([sample(sampler) for _ in 1:n])
end
falsenegativerate(s::S) where {S<:Sample} = 1 - (sum(adjacency(s.detected.metaweb) .> 0) / sum(adjacency(s.λ.metaweb)))

_get_possible(::SpeciesInteractionSampler{R,P}, λ) where {R<:Static, P<:Static} = λ
_get_possible(sampler::SpeciesInteractionSampler{R,P}, λ) where {R<:RangeGenerator, P<:Static} = begin 
    ranges = generate(sampler._range_model, richness(λ))
    possible(λ, ranges)
end
_get_possible(sampler::SpeciesInteractionSampler{R,P}, λ) where {R<:Static, P<:PhenologyGenerator} = begin
    phen = generate(sampler._phenology_model, richness(λ))
    possible(λ, phen)
end
_get_possible(sampler::SpeciesInteractionSampler{R,P}, λ) where {R<:RangeGenerator, P<:PhenologyGenerator} = begin
    ranges = generate(sampler._range_model, richness(λ))
    phen = generate(sampler._phenology_model, richness(λ))
    possible(λ, ranges, phen)
end

function sample(sampler::SpeciesInteractionSampler{R,S}) where {R,S}
    net = generate(sampler._feasibility_model)
 
    λ = Metaweb(Feasible, net.species, Global(net.scale.network), copy(net.metaweb))

    abd = generate(sampler._abundance_model, net)
    δ = detectability(sampler._detection_model, net, abd)

    poss = _get_possible(sampler, net)
    realizable!(sampler._realization_model, poss, abd)
    realize!(poss)
    detect!(poss, δ)
    return Sample(λ, poss)
end
