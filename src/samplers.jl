
struct Static end

@kwdef struct SpeciesInteractionSampler
    _feasibility_model = NicheModel()
    _range_model = Static
    _phenology_model = Static
    _abundance_model = NormalizedLogNormal()
    _realization_model = NeutrallyForbiddenLinks()
    _detection_model = RelativeAbundanceScaled()
end

struct Sample{L,A,D,G,T,Z,DT}
    λ::L
    abd::A
    δ::D
    γ::G
    θ::T
    ζ::Z
    detected::DT
end
Base.show(io::IO, s::Sample) = tprint(io, "Sample with FNR = $(falsenegativerate(s))")

function sample(sampler::SpeciesInteractionSampler, n::Integer)
    [sample(sampler) for _ in 1:n]
end
falsenegativerate(s::S) where {S<:Sample} = 1 - (sum(adjacency(s.detected.metaweb) .> 0) / sum(adjacency(s.λ.metaweb)))

function sample(sampler::SpeciesInteractionSampler)
    λ = generate(sampler._feasibility_model)
    abd = generate(sampler._abundance_model, λ)
    δ = detectability(sampler._detection_model, λ, abd)
    if sampler._range_model == Static && sampler._phenology_model <: Static
        θ = realizable(sampler._realization_model, λ, abd)
        ζ = realize(θ)
        D = detect(ζ, δ)
        Sample(λ, abd, δ, λ, θ, ζ, D)
    end
end
