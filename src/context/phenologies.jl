"""
    Phenologies{T<:AbstractSpeciesTrait} 
"""
struct Phenologies{T<:AbstractSpeciesTrait} 
    data::T
end
numspecies(p::Phenologies) = numspecies(p.data)
Base.show(io::IO, phenologies::Phenologies{T}) where {T} = print(io, "Species Phenologies for N timepoints for $(numspecies(phenologies)) species")
