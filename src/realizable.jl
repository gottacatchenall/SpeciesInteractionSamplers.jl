struct NeutrallyForbiddenLinks <: RealizationModel
    relative_abundance::Abundance{RelativeAbundance}
    energy # TODO: refactor so energy is a scalar/tensor that matches the scale of the network `realizable` is called on 
end
struct Equal <: RealizationModel end

function _rate_matrix(localnet, relabd_mat, energy)
    if !isnothing(localnet)
        #rates = Quantitative(zeros(Float32, size(localnet)))
        #rate_network = SpeciesInteractionNetwork(localnet.nodes, rates)
        ra_sum = 0.0
        adj = adjacency(localnet)
        θ = zeros(Float32, size(adj))
        if sum(adj) > 0
            for idx in findall(adj)
                θᵢⱼ = relabd_mat[idx[1], idx[2]]
                ra_sum += θᵢⱼ
            end
            return SpeciesInteractionNetwork(
                localnet.nodes,
                Quantitative(energy .* (θ ./ ra_sum))
            )
        end
    end
end

function realizable(
    net::N,
    rm::NeutrallyForbiddenLinks
) where {N<:Union{Network{<:Feasible},Network{<:Possible}}}
    relabd, energy = rm.relative_abundance, rm.energy

    relabd_mat = relabd.abundance .* relabd.abundance'

    _scale = map(x -> _rate_matrix(x, relabd_mat, energy), net)

    Network{Realizable}(
        net.species,
        _scale,
        net.metaweb
    )
end
