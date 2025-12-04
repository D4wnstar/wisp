using CairoMakie, CoherentNoise

## Choose noise algorithm
sampler = opensimplex_2d(seed=42) |>
          s -> fbm_fractal_2d(seed=42, source=s, octaves=6, frequency=1.8, lacunarity=1.8, persistence=0.7) |>
               s -> muladd(s, 0.5, 0.5) |>
                    s -> muladd(s, 0.01, 0.99)

# Initialize noise
box_size = 2#Mpc
half_diagonal = sqrt(2) / 2 * box_size
power = 0.02
width = height = 1024
noise = Matrix(undef, width, height)
metallicity = Matrix(undef, width, height)
for i in 1:width
    for j in 1:height
        val = sample(sampler, i / width, j / height)
        noise[i, j] = val
        # To find the distance, get the distance in index units, normalize it,
        # then multiply it by the physical unit
        norm_distance = sqrt((width / 2 - i)^2 + (height / 2 - j)^2) / sqrt(width^2 + height^2)
        norm_distance = max(norm_distance, 0.005)
        distance = norm_distance * half_diagonal
        # Approximate metallicity profile as a negative power law scaled by random noise
        metallicity[i, j] = val * (1 + distance)^(-power)
    end
end

# Plot noise
f = Figure(size=(600, 900))
ax_metal = Axis(f[1, 1], title="Oxygen abundance map")
ax_noise = Axis(f[2, 1], title="Noise map")
hm_metal = heatmap!(ax_metal, metallicity, colormap=:rainbow)
hm_noise = heatmap!(ax_noise, noise, colormap=:grays)
Colorbar(f[1, 2], hm_metal)
Colorbar(f[2, 2], hm_noise)
display(f)