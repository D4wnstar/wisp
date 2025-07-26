using DynamicQuantities.Constants: eps_0

abstract type AbstractWave end

mutable struct Wave <: AbstractWave
    field::Vector{Real}
    position::Vector{Real}
    wavelength::Real
    phase_shift::Real
    velocity::Real
end

mutable struct Wave1D <: AbstractWave
    field::Quantity
    position::Quantity
    wavelength::Quantity
    phase_shift::Quantity
    velocity::Quantity
end

Base.broadcastable(w::AbstractWave) = Ref(w)

wavenumber(wave::AbstractWave) = inv(wave.wavelength)
frequency(wave::AbstractWave) = wave.velocity / wave.wavelength
wavenumber_ang(wave::AbstractWave) = 2π * wavenumber(wave)
frequency_ang(wave::AbstractWave) = 2π * frequency(wave)

# The irradiance/intensity is measured using the (co)sine average in time
# so that <E₀²>ₜ = 1/2 * E₀²
irradiance(wave::AbstractWave) = wave.velocity * eps_0 * 0.5wave.field^2