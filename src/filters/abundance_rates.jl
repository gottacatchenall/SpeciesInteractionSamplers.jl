abstract type AbundanceCombinationMode end 

struct AbundanceSum <: AbundanceCombinationMode end 
(::AbundanceSum)(Aᵢ, Aⱼ) = (Aᵢ + Aⱼ)

struct AbundanceProduct <: AbundanceCombinationMode end 
(::AbundanceProduct)(Aᵢ, Aⱼ) = Aᵢ * Aⱼ

struct AbundanceMean <: AbundanceCombinationMode end 
(::AbundanceMean)(Aᵢ, Aⱼ) = 0.5(Aᵢ + Aⱼ)

struct AbundanceMin <: AbundanceCombinationMode end 
(::AbundanceMin)(Aᵢ, Aⱼ) = min(Aᵢ,Aⱼ)

struct AbundanceGeometricMean <: AbundanceCombinationMode end 
(::AbundanceGeometricMean)(Aᵢ, Aⱼ) =  sqrt(Aᵢ * Aⱼ)

struct CustomAbundanceRule <: AbundanceCombinationMode 
    rule::Function # Maps (abundance_i, abundance_j) -> rate for i,j
end 
(rule::CustomAbundanceRule)(Aᵢ, Aⱼ) =  rule.rule(Aᵢ, Aⱼ)

