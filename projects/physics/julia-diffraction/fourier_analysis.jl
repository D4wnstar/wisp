using Plots
using PlotThemes
using FFTW

theme(:dark)

t = -π:0.01:π
freq = 3
wavefunc(t::Real) = cos(freq * 2π * t) * exp(-π * t^2)
y = wavefunc.(t)
transform_arg = [wavefunc(ti) * exp(-im * 2π * freq * ti) for ti in t]
transform = fft(y)

p = plot(
    t,
    [y real.(transform_arg) imag.(transform_arg) abs.(transform)],
    layout=(4, 1),
    title=[
        "Waveform";;
        "Real part of transform argument at $(freq)Hz";;
        "Imaginary part of transform argument at $(freq)Hz";;
        "Transform"
    ],
    size=(700, 1000),
    legend=false,
)

savefig(p, "plots/transform.png")