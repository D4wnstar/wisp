using LinearAlgebra
using PlotThemes
using Plots
using LaTeXStrings
using QuadGK

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

"""Mehler kernel"""
function propagator(x, y, t, m, ω)
    sqrt(m * ω / (2π * im * ħ * sin(ω * t))) *
    exp(im * m * ω / (2ħ * sin(ω * t)) * ((x^2 + y^2) * cos(ω * t) - 2x * y))
end

function ψ_t(x, t, m, ω, initial_state::Function)
    quadgk(y -> propagator(x, y, t, m, ω) * initial_state(y, m, ω), -Inf, +Inf)[1]
end

period(ω) = 2π / ω

x = -3:0.01:3
m = 2
ω = 1

# Since eigenstates are stationary, propagating them wouldn't give interesting results
# We can instead start from a linear combination of states
initial_state(x, m, ω) = (ψ_0(x, m, ω) + ψ_1(x, m, ω)) / √2

@time anim = @animate for (i, t) in enumerate(0:0.1:period(ω))
    println("Calculating time $t...")
    if i == 1
        state = initial_state.(x, m, ω)
        yreal = real(state)
        yimag = imag(state)
        yt = abs2.(state)
    else
        state = ψ_t.(x, t, m, ω, initial_state)
        yreal = real(state)
        yimag = imag(state)
        yt = abs2.(state)
    end
    t = @sprintf("%.2f", t)

    plot(
        x,
        [[yreal yt], yimag],
        ylims=[(-1, 1) (0, 1)],
        label=[["Real part" L"\frac{\psi_{0}+\psi_{1}}{\sqrt{2}}"] "Imaginary part"],
        xlabel=L"x",
        ylabel=L"Probability $|\psi(x,t)|^2$",
        title=L"Time evolution of a quantum harmonic oscillator state ($t=%$t$)",
        size=(900, 1200),
        layout=(2, 1),
    )
end fps = 30
# The discontinuity of the real and imaginary parts in time is due to the Julia complex sqrt
# function having a branch cut over negative reals

gif(anim, "plots/oscillator_time_evo_psi0_psi1.gif")