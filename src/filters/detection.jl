
"""
    BinomialDetection

Detected interactions follow a binomial process: Dᵢⱼ ~ Binomial(ζᵢⱼ, δᵢⱼ)
"""
struct BinomialDetection{T} <: DetectabilityModel
    probability::T  # Can be scalar, vector, or array
end

BinomialDetection(; prob=0.5) = BinomialDetection(prob)

_binomial_detection(n,p) = x > 0 ? rand(Binomial(n,p)) : 0 

"""
    detect(
        layer::NetworkLayer{<:Integer,Realized}, 
        model::DetectabilityModel
    )

Transforms Realized → Detected via observation process.

Dᵢⱼ ~ Binomial(ζᵢⱼ, δᵢⱼ)
"""
function detect(
    layer::NetworkLayer{Realized}, 
    model::BinomialDetection
) 
    realized = layer.data
    prob = model.probability
        
    if prob isa Number 
        detected = map(x-> x > 0 ? rand(Binomial(x, prob)) : 0, realized)
    else 
        detected = broadcast_dims((n,p)-> n > 0 ? rand(Binomial(n,p)) : 0, realized, prob)
    end

    metadata = merge(layer.metadata, Dict(:detection_model => model))
    NetworkLayer(Detected(), getspecies(layer), detected, metadata)
end
    

"""
    PerfectDetection

    All realized interactions are detected.
"""
struct PerfectDetection <: DetectabilityModel end

function detect(
    layer::NetworkLayer{Realized}, 
    ::PerfectDetection
)
    NetworkLayer(
        Detected(),
        getspecies(layer),
        copy(layer.data),
        merge(layer.metadata, Dict(:detection_model => PerfectDetection()))
    )
end


# =================================================================================
#
# Abundance Detection Rules
#
# =================================================================================

abstract type AbstractDetectabilityRule end 

struct LinearDetectablity <: AbstractDetectabilityRule 
    coefficient
end 
(lindet::LinearDetectablity)(rᵢ) = max(min(lindet.coefficient * rᵢ, 1), 0)

struct ExponentialDetectability <: AbstractDetectabilityRule 
    coefficient
end 
(expdet::ExponentialDetectability)(rᵢ) = 1 - (1-rᵢ)^expdet.coefficient


"""
    AbundanceScaledDetection
"""
struct AbundanceScaledDetection{A,S,R} <: DetectabilityModel 
    abundance::A
    scaling_mode::S
    combination_mode::R
end

AbundanceScaledDetection(abundance; scaling_mode = ExponentialDetectability(5.), combination_mode=DetectabilityProduct()) = AbundanceScaledDetection(abundance, scaling_mode, combination_mode)

function _get_detection_rate(::NetworkLayer{Realized,UnipartiteSpeciesPool}, model::AbundanceScaledDetection)
    abundances = model.abundance 
    detect_probs = broadcast_dims(model.scaling_mode, abundances.data.data)
    detect_probs2 = set(detect_probs, :species => :species2)
    detection_rate = @d broadcast_dims(model.combination_mode, detect_probs, detect_probs2)
    return detection_rate
end


function _get_detection_rate(::NetworkLayer{Realized,BipartiteSpeciesPool}, model::AbundanceScaledDetection)
    specieswise_detection = [model.scaling_mode.(x) for x in collect(values(model.abundance.data.dict))]
    detection_rate = broadcast_dims(model.combination_mode,specieswise_detection...)
    return detection_rate
end

function detect(
    layer::NetworkLayer{Realized}, 
    model::AbundanceScaledDetection
) 
    realized = layer.data
    detect_rate = _get_detection_rate(layer, model)
    detected = broadcast_dims((n,p)-> n > 0 ? rand(Binomial(n,p)) : 0, realized, detect_rate)

    metadata = merge(layer.metadata, Dict(:detection_model => model))
    NetworkLayer(Detected(), getspecies(layer), detected, metadata)
end
    