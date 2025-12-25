
"""
    BinomialDetection

Detected interactions follow a binomial process: Dᵢⱼ ~ Binomial(ζᵢⱼ, δᵢⱼ)
"""
struct BinomialDetection{T} <: DetectabilityModel
    probability::T  # Can be scalar, vector, or array
    effort::Union{Int,AbstractArray{Int}}  # Sampling effort
end

BinomialDetection(; prob=0.5, effort=1) = BinomialDetection(prob, effort)

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
        detected = broadcast_dims(_binomial_detection, realized.data, prob);
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
