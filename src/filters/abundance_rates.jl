# =================================================================================
#
# Combination Rules
#
# =================================================================================

"""
    AbstractCombinationMode
"""
abstract type AbstractCombinationMode end 
struct SumCombination <: AbstractCombinationMode end 
(::SumCombination)(x,y) = (x,y)

struct ProductCombination <: AbstractCombinationMode end 
(::ProductCombination)(x,y) = x*y

struct MeanCombination <: AbstractCombinationMode end 
(::MeanCombination)(x,y) = 0.5(x+y)

struct GeometricMeanCombination <: AbstractCombinationMode end 
(::GeometricMeanCombination)(x,y) = sqrt(x*y)

struct MinCombination <: AbstractCombinationMode end 
(::MinCombination)(x,y) = min(x, y)

struct MaxCombination <: AbstractCombinationMode end 
(::MaxCombination)(x,y) = max(x, y)


# =================================================================================
#
# Abundance Combination Rules
#
# =================================================================================

abstract type AbundanceCombinationMode <: AbstractCombinationMode end 
struct AbundanceSum <: AbundanceCombinationMode end 
(::AbundanceSum)(Aᵢ, Aⱼ) = SumCombination()(Aᵢ, Aⱼ)

struct AbundanceProduct <: AbundanceCombinationMode end 
(::AbundanceProduct)(Aᵢ, Aⱼ) = ProductCombination()(Aᵢ, Aⱼ)

struct AbundanceMean <: AbundanceCombinationMode end 
(::AbundanceMean)(Aᵢ, Aⱼ) = MeanCombination()(Aᵢ, Aⱼ)

struct AbundanceMin <: AbundanceCombinationMode end 
(::AbundanceMin)(Aᵢ, Aⱼ) = MinCombination()(Aᵢ,Aⱼ)

struct AbundanceMax <: AbundanceCombinationMode end 
(::AbundanceMax)(Aᵢ, Aⱼ) = MaxCombination()(Aᵢ,Aⱼ)

struct AbundanceGeometricMean <: AbundanceCombinationMode end 
(::AbundanceGeometricMean)(Aᵢ, Aⱼ) =  GeometricMeanCombination()(Aᵢ, Aⱼ)

struct CustomAbundanceRule <: AbundanceCombinationMode 
    rule::Function # Maps (abundance_i, abundance_j) -> rate for i,j
end 
(rule::CustomAbundanceRule)(Aᵢ, Aⱼ) =  rule.rule(Aᵢ, Aⱼ)


# =================================================================================
#
# Detection Combination Rules
#
# =================================================================================

abstract type DetectionCombinationMode <: AbstractCombinationMode end 

struct DetectabilitySum <: DetectionCombinationMode end 
(::DetectabilitySum)(Aᵢ, Aⱼ) = SumCombination()(Aᵢ, Aⱼ)

struct DetectabilityProduct <: DetectionCombinationMode end 
(::DetectabilityProduct)(Aᵢ, Aⱼ) = ProductCombination()(Aᵢ, Aⱼ)

struct DetectabilityMean <: DetectionCombinationMode end 
(::DetectabilityMean)(Aᵢ, Aⱼ) = MeanCombination()(Aᵢ, Aⱼ)

struct DetectabilityMin <: DetectionCombinationMode end 
(::DetectabilityMin)(Aᵢ, Aⱼ) = MinCombination()(Aᵢ,Aⱼ)

struct DetectabilityMax <: DetectionCombinationMode end 
(::DetectabilityMax)(Aᵢ, Aⱼ) = MaxCombination()(Aᵢ,Aⱼ)

struct DetectabilityGeometricMean <: DetectionCombinationMode end 
(::DetectabilityGeometricMean)(Aᵢ, Aⱼ) =  GeometricMeanCombination()(Aᵢ, Aⱼ)

struct CustomDetectabilityRule <: DetectionCombinationMode 
    rule::Function # Maps (abundance_i, abundance_j) -> rate for i,j
end 
(rule::CustomDetectabilityRule)(Aᵢ, Aⱼ) =  rule.rule(Aᵢ, Aⱼ)
