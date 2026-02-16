
# =================================================================================
#
# Trait Kernels
#
# =================================================================================

"""
    TraitKernel

Abstract supertype for kernel functions that transform pairwise trait distances
into interaction affinities.
"""
abstract type TraitKernel end

"""
    GaussianKernel

Gaussian kernel: k(d) = exp(-d² / (2σ²))
"""
struct GaussianKernel{T} <: TraitKernel
    sigma::T
end
GaussianKernel() = GaussianKernel(1.0)
(k::GaussianKernel)(d) = exp(-d^2 / (2 * k.sigma^2))

Base.show(io::IO, k::GaussianKernel) = print(io, "GaussianKernel(σ=$(k.sigma))")

"""
    ExponentialKernel

Exponential kernel: k(d) = exp(-d / σ)
"""
struct ExponentialKernel{T} <: TraitKernel
    sigma::T
end
ExponentialKernel() = ExponentialKernel(1.0)
(k::ExponentialKernel)(d) = exp(-d / k.sigma)

Base.show(io::IO, k::ExponentialKernel) = print(io, "ExponentialKernel(σ=$(k.sigma))")

"""
    _pairwise_euclidean(traits_i, traits_j)

Compute the pairwise Euclidean distance matrix between two trait matrices.
`traits_i` is n_i × p and `traits_j` is n_j × p. Returns n_i × n_j matrix.
"""
function _pairwise_euclidean(traits_i::AbstractMatrix, traits_j::AbstractMatrix)
    ni = size(traits_i, 1)
    nj = size(traits_j, 1)
    D = zeros(ni, nj)
    for j in 1:nj, i in 1:ni
        D[i, j] = sqrt(sum((traits_i[i, :] .- traits_j[j, :]) .^ 2))
    end
    return D
end

