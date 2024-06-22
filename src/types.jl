abstract type GenerationModel end

abstract type NetworkGenerator <: GenerationModel end
abstract type AbundanceGenerator <: GenerationModel end
abstract type PhenologyGenerator <: GenerationModel end
abstract type RangeGenerator <: GenerationModel end

abstract type State end
abstract type Feasible <: State end
abstract type Possible <: State end
abstract type Realizable <: State end
abstract type Realized <: State end
abstract type Detectable <: State end
abstract type Detected <: State end


abstract type Scale end

abstract type AbundanceTrait end
abstract type RelativeAbundance <: AbundanceTrait end
abstract type Density <: AbundanceTrait end
abstract type Count <: AbundanceTrait end


abstract type RealizationModel end
abstract type DetectionModel end

