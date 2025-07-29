using DynamicQuantities

include("waves.jl")

"This assumes the far field approximation where `distance` ≫ `slit_width`"
function irradiance_single_slit(
    x::Quantity,
    wave::AbstractWave,
    slit_width::Quantity,
    distance::Quantity,
)
    β = abs(wavenumber_ang(wave)) * 0.5slit_width * x / distance
    return irradiance(wave) * (sin(β) / β)^2
end

"""
This assumes the far field approximation where `distance` ≫ `slit_width`.
Also, the slits are both the same width. `slit_distance` refers to the length of
space in between the two slits.
"""
function irradiance_double_slit(
    x::Quantity,
    wave::AbstractWave,
    slit_width::Quantity,
    slit_distance::Quantity,
    distance::Quantity,
)
    k = abs(wavenumber_ang(wave))
    β = k * 0.5slit_width * x / distance
    d = (2slit_width + slit_distance) / 2
    return irradiance(wave) * (sin(β) / β)^2 * cos(k * slit_width * x / distance)^2
end

"This assumes the far field approximation where `distance` ≫ `slit_radius`"
function irradiance_circular_slit(
    q::Quantity,
    wave::AbstractWave,
    slit_radius::Quantity,
    distance::Quantity,
)
    k = abs(wavenumber_ang(wave))
    ρ = k * slit_radius * q / distance |> ustrip
    I = irradiance(wave) * (2besselj1(ρ) / ρ)^2
    return I / exp(ustrip(-200q)) # dampens the center peak to show the tails better
end

"This assumes the far field approximation where `distance` ≫ `slit_width` and `slit_height`"
function irradiance_rectangular_slit(
    x::Quantity,
    y::Quantity,
    wave::AbstractWave,
    slit_width::Quantity,
    slit_height::Quantity,
    distance::Quantity,
)
    k = abs(wavenumber_ang(wave))
    α = k * 0.5slit_width * x / distance
    β = k * 0.5slit_height * y / distance
    I = irradiance(wave) * (sin(α) / α)^2 * (sin(β) / β)^2
    return I / exp(ustrip(-15abs(x) - 15abs(y))) # dampens the center peak to show the tails better
end