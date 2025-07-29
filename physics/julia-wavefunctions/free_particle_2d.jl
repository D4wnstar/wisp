using LinearAlgebra
using PlotThemes
using Plots
using LaTeXStrings
using HCubature

theme(:dracula)

ħ = 2

@inline ψ_0(y1, y2, p1, p2) = exp(-(y1^2 + y2^2) + im * (p1 * y1 + p2 * y2) / ħ)

@inline function integrand(x1, x2, y1, y2, t, m, p1, p2)
    exp(im * m * ((x1 - y1)^2 + (x2 - y2)^2) / (2ħ * t)) * ψ_0(y1, y2, p1, p2)
end
function ψ_t(x1, x2, t, m, p1, p2)
    m / (2im * t * π * ħ) *
    hcubature(
        y -> integrand(x1, x2, y[1], y[2], t, m, p1, p2),
        [-20, -20], # Using -Inf and +Inf outputs NaNs for reasons I can't figure out
        [+20, +20], # so we are using an interval large enough to contain the grand majority of the integral
        rtol=0.01,  # Relative tolerance set to 1% because that's good enough for a visualization
        # and speeds up the function from ~246 ms to ~2.7 ms (or ~90 times) on well-behaving points
        maxevals=100_000, # The number of evals for points very far from the peak blows up exponentially
        # and gives almost no benefit (the integral is ~0 around that point anyway) so we cap the
        # number of evals to give an upper bound to performance
    )[1]
end

m = 2.0
p1 = p2 = 1.0

xr = -2:0.2:3
x = Iterators.product(xr, xr) |> collect

@time anim = @animate for (i, t) in enumerate(0:0.05:2)
    println("Calculating time $t...")
    if i == 1
        state = map((xn) -> norm(ψ_0(xn[1], xn[2], p1, p2))^2, x)
    else
        state = map((xn) -> norm(ψ_t(xn[1], xn[2], t, m, p1, p2))^2, x)
    end
    t = @sprintf("%.2f", t)

    surface(
        xr,
        xr,
        state,
        legend=false,
        zlims=(0, 1),
        xlabel=L"x",
        ylabel=L"y",
        zlabel=L"|\psi|^2",
        title=L"Free particle position distribution at time $t=%$t$",
        size=(800, 600),
    )
end fps = 6

gif(anim, "plots/free_particle_2d.gif")