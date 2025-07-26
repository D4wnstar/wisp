using LinearAlgebra
using PlotThemes
using Plots
using LaTeXStrings

theme(:dracula)

ħ = 2

# Excited states have been derived manually from Hermite functions in natural units
# SI units have then been added back and renormalized
ψ_0(x, m, ω) = (m * ω / (π * ħ))^(1 / 4) * exp(-(m * ω / 2ħ) * x^2)
ψ_1(x, m, ω) = (m * ω / (π * ħ))^(1 / 4) * sqrt(2m * ω / ħ) * x * exp(-(m * ω / 2ħ) * x^2)
function ψ_2(x, m, ω)
    π^(-1 / 8) * (2m * ω / (π * ħ))^(1 / 4) * (1 / √2) * (2m * ω * x^2 / ħ - 1) *
    exp(-(m * ω / 2ħ) * x^2)
end

x = -3:0.01:3
m = 2
ω = 1

y0 = @. norm(ψ_0(x, m, ω))^2
y1 = @. norm(ψ_1(x, m, ω))^2
y2 = @. norm(ψ_2(x, m, ω))^2

p = plot(
    x,
    [y0 y1 y2],
    label=["Ground state" "First excited state" "Second excited state"],
    ylims=(0, 1),
    xlabel=L"x",
    ylabel=L"Probability $|\psi|^2$",
    title="Position distribution for eigenstates of a quantum harmonic oscillator",
    size=(800, 600),
)

savefig(p, "plots/oscillator_eigenstates.png")