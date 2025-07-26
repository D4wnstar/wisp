using LinearAlgebra
using PlotThemes
using Plots
using LaTeXStrings
using QuadGK
using Printf

theme(:dracula)

ħ = 2

ψ_0(y, p_0) = exp(-y^2 + im * p_0 * y / ħ)

integrand(x, y, t, m, p_0) = exp(im * m * (x - y)^2 / (2ħ * t) - y^2 + im * p_0 * y / ħ)
function ψ_t(x, t, m, p_0)
    @inline sqrt(m / (2im * t * π * ħ)) *
            quadgk(y -> integrand(x, y, t, m, p_0), -Inf, +Inf, rtol=0.0001)[1]
end

modulo_sq(x, t, m, p_0) = norm(ψ_t(x, t, m, p_0))^2

function make_alphas(len::Integer; decay=0.1)
    alphas = ones(len)
    for i in eachindex(alphas)
        alphas[i] = max(alphas[i] - decay * (len - i), 0)
    end
    return alphas
end

x = -2:0.1:5
m = 2
p_0 = 1

y_vals = []
alphas = []

@time anim = @animate for (i, t) in enumerate(0:0.05:4)
    println("Calculating time $t...")
    if i == 1
        init_state = norm.(ψ_0.(x, p_0)) .^ 2
        push!(y_vals, init_state)
        alphas = [1]'
    else
        new_state = modulo_sq.(x, t, m, p_0)
        push!(y_vals, new_state)
        alphas = make_alphas(i, decay=0.2)'
    end
    t = @sprintf("%.2f", t)

    plot(
        x,
        y_vals,
        legend=false,
        alpha=alphas,
        xlims=(-2, 5),
        ylims=(0, 1),
        xlabel=L"x",
        ylabel=L"|\psi|^2",
        color=:cyan,
        title=L"Free particle position distribution at time $t=%$t$",
    )
end fps = 12

gif(anim, "plots/free_particle_1d.gif")
