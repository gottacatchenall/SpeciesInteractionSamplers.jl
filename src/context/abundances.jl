"""
    Abundances{T<:AbstractSpeciesTrait} 
"""
struct Abundances{T<:AbstractSpeciesTrait}
    data::T
end
Base.getindex(abd::Abundances, i) = abd.data[i]
