using Plots
using PlotThemes
using DynamicQuantities
using DynamicQuantities.Units: m, cm, mm, nm, V
using DynamicQuantities.Constants: c

theme(:dark)

include("waves.jl")
include("slits.jl")

s = 4m # distance between slit and screen
y = range(-2cm, 2cm, length=1000) # values where the irradiance is sampled on the screen
λ1 = 400nm
λ2 = 500nm # the wavelength of the wave
λ3 = 600nm
λ4 = 700nm
d = 0.42mm # slit width

wave_400 = Wave1D(9V / m, 0m, λ1, 0, c)
wave_500 = Wave1D(9V / m, 0m, λ2, 0, c)
wave_600 = Wave1D(9V / m, 0m, λ3, 0, c)
wave_700 = Wave1D(9V / m, 0m, λ4, 0, c)

I1 = irradiance_single_slit.(y, wave_400, d, s) .|> ustrip
I2 = irradiance_single_slit.(y, wave_500, d, s) .|> ustrip
I3 = irradiance_single_slit.(y, wave_600, d, s) .|> ustrip
I4 = irradiance_single_slit.(y, wave_700, d, s) .|> ustrip

p = plot(
    ustrip.(y),
    [I1, I2, I3, I4],
    title="Intensity profile of single slit diffraction",
    xlabel="Distance from center of slit",
    ylabel="Intensity",
    label=reduce(hcat, ["$(wl)nm" for wl in ["400", "500", "600", "700"]]),
    size=(1400, 1200),
    left_margin=(6.0, :mm),
)
# plot!(ustrip.(y), ustrip.(I2), label="532nm")
# plot!(ustrip.(y), ustrip.(I3), label="450nm")

savefig(p, "plots/single_slit.png")