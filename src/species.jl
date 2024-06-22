struct SpeciesPool{S<:Union{String,Symbol}}
    names::Vector{S}
end

Base.length(sp::SpeciesPool) = length(sp.names)
Base.getindex(sp::SpeciesPool, i) = sp.names[i]

