using Plots
using PlotThemes
using DynamicQuantities
using DynamicQuantities.Units: m, cm, mm, nm, V
using DynamicQuantities.Constants: c
using FFTW

theme(:dark)

include("waves.jl")
include("slits.jl")

# As the diffraction pattern of a slit is effectively the Fourier transform of the
# irradiance incident on a surface after passing through the slit.
# Taking the transform of the diffraction pattern effectively undoes the diffraction
# and gives the shape of the slit.
"Take a 2D diffraction pattern and render the shape of the slit from which it came."
function render_slit_shape(
    x::AbstractVector,
    y::AbstractVector,
    irradiance_profile::AbstractMatrix;
    zoom::Int=10,
)
    transform = fft(irradiance_profile) |> fftshift
    abs_transform = abs.(transform)
    zoom_limit_x, zoom_limit_y = size(abs_transform) .÷ zoom
    x_half = length(x) ÷ 2
    y_half = length(y) ÷ 2
    heatmap(
        x,
        y,
        [abs_transform, abs_transform],
        title=["Fourier transform of diffraction" "Zoom"],
        aspectratio=1,
        xlims=[:auto (x[x_half-zoom_limit_x], x[x_half+zoom_limit_x])],
        ylims=[:auto (y[y_half-zoom_limit_y], y[y_half+zoom_limit_y])],
        layout=(1, 2),
        size=(800, 400),
    )
end

wave = Wave1D(9V / m, 0m, 400nm, 0, c)

# Rectangular slit
x = range(-20cm, 20cm, length=1000) # values where the irradiance is sampled on the screen
y = range(-20cm, 20cm, length=1000)
w = 0.12mm # slit width
h = 0.12mm # slit height
s = 4m # distance between slit and screen

I_rect = zeros(length(x), length(y))
for (i, xi) in enumerate(x)
    for (j, yj) in enumerate(y)
        I_rect[i, j] = irradiance_rectangular_slit(xi, yj, wave, w, h, s) |> ustrip
    end
end

p_rect = render_slit_shape(x .|> ustrip, y .|> ustrip, I_rect)

savefig(p_rect, "plots/rect_slit_transform.png")

# Circular slit
x = range(-1cm, 1cm, length=1000) # values where the irradiance is sampled on the screen
y = range(-1cm, 1cm, length=1000)
R = 3mm # slit radius

I_circ = zeros(size(xy))
for (i, xi) in enumerate(x)
    for (j, yj) in enumerate(y)
        r = √(xi^2 + yj^2)
        I_circ[i, j] = irradiance_circular_slit(r, wave, R, s) |> ustrip
    end
end

p_circ = render_slit_shape(x .|> ustrip, x .|> ustrip, I_circ)

savefig(p_circ, "plots/circ_slit_transform.png")
