
"""
    Ranges{T<:AbstractSpeciesTrait}
"""
struct Ranges{T<:AbstractSpeciesTrait}
    data::T
end
numspecies(r::Ranges) = numspecies(r.data)
Base.show(io::IO, ranges::Ranges{T}) where {T} = print(io, "Species Ranges in for XX species")
Base.getindex(r::Ranges, species_name::Symbol) = r.data[species_name,:,:]
