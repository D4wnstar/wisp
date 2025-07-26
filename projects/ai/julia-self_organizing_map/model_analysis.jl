using LinearAlgebra, CSV, DataFrames, Plots, MLDatasets

"""Find the nearest neuron to the given point `x` in the grid `weights`."""
function find_nearest(x::Vector, weights::Array)
    i_nearest = 1
    j_nearest = 1
    shortest_dist = Inf
    for i in axes(weights, 1)
        for j in axes(weights, 2)
            curr_dist = norm(x - weights[i, j, 1])
            if curr_dist < shortest_dist
                shortest_dist = curr_dist
                i_nearest = i
                j_nearest = j
            end
        end
    end

    return (i_nearest, j_nearest)
end

iris = Iris()

# Normalize inputs
norm_const = maximum([maximum(iris.dataframe[:, i]) for i in axes(iris.features, 2)])
setosa = filter(row -> occursin("setosa", row.class), iris.dataframe)[!, 1:4] ./ norm_const
versi = filter(row -> occursin("versicolor", row.class), iris.dataframe)[!, 1:4] ./ norm_const
virgi = filter(row -> occursin("virginica", row.class), iris.dataframe)[!, 1:4] ./ norm_const

# FIXME: This script currently only works for a 50x50 model
weights_df = CSV.read("data/full_model_50x50.csv", DataFrame)
weights = Matrix(weights_df)
weights = reshape([weights[:, i] for i in 1:size(weights, 2)], 50, 50)

# Match samples with their closest neuron to overlay them on the heatmaps
setosa_x, versi_x, virgi_x = [], [], []
setosa_y, versi_y, virgi_y = [], [], []
for row in Vector.(eachrow(setosa))
    coords = find_nearest(row, weights)
    push!(setosa_x, coords[1])
    push!(setosa_y, coords[2])
end
for row in Vector.(eachrow(versi))
    coords = find_nearest(row, weights)
    push!(versi_x, coords[1])
    push!(versi_y, coords[2])
end
for row in Vector.(eachrow(virgi))
    coords = find_nearest(row, weights)
    push!(virgi_x, coords[1])
    push!(virgi_y, coords[2])
end

function plot_neighbor_distance(weights::Array)
    distances = zeros(size(weights, 1), size(weights, 2))
    for i in axes(weights, 1)
        for j in axes(weights, 2)
            for m in -1:1
                if i + m < 1 || i + m > size(weights, 1)
                    continue
                end
                for l in -1:1
                    if j + l < 1 || j + l > size(weights, 2)
                        continue
                    end
                    distances[i, j] += norm(weights[i, j] - weights[i+m, j+l])
                end
            end
        end
    end

    return heatmap(
        distances,
        title="Overlay of data points on U-Matrix",
        size=(600, 550),
    )
end

"""Analyse the weights by plotting a heatmap of the neuron's weight norms,
distance from neighbors and norms of components. Since the components
are defined in input-space, they represent the dimensions of petals/sepals and can
be used to find their areas.
"""
function plot_analysis(weights, xres=1000, yres=800; overlay=false)
    weight_magnitudes = [norm(weights[i, j]) for i in axes(weights, 1), j in axes(weights, 2)]
    sepal_area =
        [weights[i, j][1] * weights[i, j][2] * norm_const^2 for i in axes(weights, 1), j in axes(weights, 2)]
    petal_area =
        [weights[i, j][3] * weights[i, j][4] * norm_const^2 for i in axes(weights, 1), j in axes(weights, 2)]

    p = plot(
        heatmap(weight_magnitudes),
        plot_neighbor_distance(weights),
        contourf(1:50, 1:50, petal_area),
        contourf(1:50, 1:50, sepal_area),
        layout=(2, 2),
        legend=false,
        size=(xres, yres),
        title=["Magnitude of weights" "Distance from neighbors" "Petal area" "Sepal area"],
    )

    if overlay
        x = [setosa_x, versi_x, virgi_x]
        y = [setosa_y, versi_y, virgi_y]
        p = scatter!(
            [y, y, y, y],
            [x, x, x, x],
            label=["Setosa" "Versicolor" "Virginica"],
            marker=[:square :diamond :hexagon],
            markercolor=[:cyan :orange :green1],
            legend=:outerbottom,
            legend_column=-1,
            size=(xres, yres),
        )
    end

    return p
end

analysis = plot_analysis(weights)
savefig(analysis, "plots/analysis_full_50x50.png")

overlay = plot_analysis(weights; overlay=true)
savefig(overlay, "plots/analysis_overlay_full_50x50.png")
