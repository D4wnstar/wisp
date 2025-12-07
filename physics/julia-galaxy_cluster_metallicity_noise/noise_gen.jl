using CairoMakie, CoherentNoise

## Metallicity profiles
metal_profile(x::Real; amp=0.75, scale=4, power=1.2) = amp / (1 + scale * x)^power
solar_fe_abundance = 0.00125 # Anders & Grevesse 1989, as mass fraction Z_{Fe, sun}
cluster_fe_abundance = solar_fe_abundance / 3 # Rough estimate from known ICM behavior
cluster_h_abundance = 0.71 # Loose estimate starting from solar abundances
cluster_fe_to_h = cluster_fe_abundance / cluster_h_abundance # Fe abundance w.r.t. H abundance

## Choose noise algorithm
sampler = opensimplex2_2d(seed=42) |> # Start with OpenSimplex2 noise
          s -> fbm_fractal_2d(seed=42, source=s, octaves=5, frequency=2.2, lacunarity=1.8, persistence=0.7) |> # Layer it with a fractal Brownian motion sampler
               s -> muladd(s, 0.5, 0.5) |> # Scale from [-1, 1] to [0, 1]
                    s -> muladd(s, 0.5, 0.75) # Scale to [0.75, 1.25] for random ±25% scalings

# Create noisy map
box_size = 2#Mpc
half_diagonal = sqrt(2) / 2 * box_size
radius_scale = 1.5#Mpc
width = height = 1024
noise = Matrix(undef, width, height)
metallicity = Matrix(undef, width, height)
for i in 1:width
    for j in 1:height
        noise_sample = sample(sampler, i / width, j / height)
        noise[i, j] = noise_sample
        # To find the distance, get the distance in matrix index units, normalize it,
        # then multiply it by the physical unit
        norm_distance = sqrt((width / 2 - i)^2 + (height / 2 - j)^2) / sqrt(width^2 + height^2)
        r = norm_distance * half_diagonal / radius_scale
        metallicity[i, j] = noise_sample * metal_profile(r) * cluster_fe_to_h
    end
end

# Plot map
f = Figure(size=(1000, 900))
ax_metal = Axis(f[1, 1], title="Iron abundance map")
ax_noise = Axis(f[2, 1], title="Noise map")
ax_profile = Axis(
    f[1, 3],
    title="Radial metallicity profile (iron)",
    xscale=log10,
    xticks=[0.01, 0.1, 1.0],
    xlabel=L"r/r_{\text{scale}}",
    ylabel=L"Z_{\text{Fe}}/Z_{\text{Fe, Sun}}",
    limits=(nothing, nothing, 0.0, 1.0)
)
hm_metal = heatmap!(ax_metal, metallicity, colormap=:rainbow, colorrange=[0.0, maximum(metallicity)])
hm_noise = heatmap!(ax_noise, noise, colormap=:grays)
lines!(ax_profile, 0.01:0.01:half_diagonal, x -> metal_profile(x), label="No noise")
lines!(
    ax_profile,
    0.01:0.01:half_diagonal,
    x -> metal_profile(x) * sample(sampler, x / half_diagonal, x / half_diagonal),
    linestyle=(:dash, :dense),
    label="With noise"
)
axislegend(ax_profile)
Colorbar(f[1, 2], hm_metal, label=L"Z_{\text{Fe}}")
Colorbar(f[2, 2], hm_noise, label="Noise intensity")
display(f)
