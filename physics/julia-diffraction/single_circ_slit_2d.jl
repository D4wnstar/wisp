using LinearAlgebra
using Plots
using PlotThemes
using DynamicQuantities
using DynamicQuantities.Units: m, cm, mm, nm, V
using DynamicQuantities.Constants: c
using SpecialFunctions

theme(:dark)

include("waves.jl")
include("slits.jl")

s = 4m # distance between slit and screen
x = range(-1cm, 1cm, length=1000) # values where the irradiance is sampled on the screen
xy = Iterators.product(x, x) .|> norm # distance from center of diffraction
λ1 = 400nm # the wavelength of the wave
λ2 = 500nm # the wavelength of the wave
λ3 = 600nm # the wavelength of the wave
λ4 = 700nm # the wavelength of the wave
R = 0.5mm # slit radius

wave_400 = Wave1D(9V / m, 0m, λ1, 0, c)
wave_500 = Wave1D(9V / m, 0m, λ2, 0, c)
wave_600 = Wave1D(9V / m, 0m, λ3, 0, c)
wave_700 = Wave1D(9V / m, 0m, λ4, 0, c)

waves = [wave_400, wave_500, wave_600, wave_700]

I = [zeros(size(xy)) for _ in 1:4]
for (matrix, wave) in zip(I, waves)
    for (i, q) in enumerate(xy)
        matrix[i] = irradiance_circular_slit(q, wave, R, s) |> ustrip
    end
end

p = heatmap(
    ustrip.(x),
    ustrip.(x),
    I,
    title=reshape(
        [
            "Intensity profile of circular slit diffraction [$(wl)nm]" for
            wl in ["400", "500", "600", "700"]
        ], (1, 4)),
    xlabel="x distance from center of slit",
    ylabel="y distance from center of slit",
    colorbar_title="Intensity",
    left_margin=(6.0, :mm),
    size=(1400, 1200),
    layout=4,
    aspectratio=1,
)

savefig(p, "plots/circ_slit.png")