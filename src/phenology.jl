struct Phenology{F}
    occurrence_timeseries::Vector{F}
end
occurrence(phen::Phenology) = phen.occurrence_timeseries
Base.length(phen::Phenology) = length(occurrence(phen))
Base.show(io::IO, phen::Phenology) = begin
    p = lineplot(
        phen.occurrence_timeseries,
        xlabel="Time",
        ylabel="occurrence",
    )
    print(io, p)
end


# ========================================
#
# Generators
#
# ========================================

Base.@kwdef struct UniformPhenology{I<:Integer} <: PhenologyGenerator
    timespan::I = 100
    minimum_length::I = 5
end
function generate(pg::UniformPhenology)
    T, minlength = pg.timespan, pg.minimum_length
    timeseries = zeros(Bool, T)

    # TODO: technically this is biased by using minlength padded only from the lower side,
    # so the mean number of species is at (0.5T + 0.5minlength)
    start = rand(DiscreteUniform(1, T - minlength - 1))
    finish = rand(DiscreteUniform(start + minlength, T))
    timeseries[start:finish] .= true
    Phenology(timeseries)
end

Base.@kwdef struct PoissonPhenology{I,F} <: PhenologyGenerator
    timespan::I = 100
    mean_length::F = 20
end

function generate(pp::PP) where {PP<:PoissonPhenology}
    T, μ = pp.timespan, pp.mean_length
    timeseries = zeros(Bool, T)

    center = rand(DiscreteUniform(1, T))
    L = rand(Poisson(μ))

    start, finish = max(1, center - L), min(T, center + L)
    timeseries[start:finish] .= true
    Phenology(timeseries)
end




#=
@kwdef struct GaussianMixturePhenology <: PhenologyGenerator
    num_clusters = rand(Poisson(2))
    mu_prior = Uniform(0.1, 0.9)
    sigma_prior = Beta(4, 7)
    dx = 0.1
end

function generate(gmm::GaussianMixturePhenology)
    k, pμ, pσ = gmm.num_clusters, gmm.mu_prior, gmm.sigma_prior
    dist = [Truncated(Normal(rand(pμ), rand(pσ)), 0, 1) for _ in 1:k]

    y = map(x -> sum([pdf(d, x) for d in dist]), 0:gmm.dx:1)
    occupancy_probability = y ./ maximum(y)
    Phenology{typeof(occupancy_probability[begin])}(occupancy_probability)
end =#
