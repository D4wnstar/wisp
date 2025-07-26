using LinearAlgebra, DataFrames, CSV, MLDatasets, Plots, Random

iris = Iris()
setosa = iris.dataframe[iris.dataframe.class.=="Iris-setosa", :]
versi = iris.dataframe[iris.dataframe.class.=="Iris-versicolor", :]
virgi = iris.dataframe[iris.dataframe.class.=="Iris-virginica", :]

# Preprocess data
norm_const = maximum([maximum(iris.dataframe[:, i]) for i in axes(iris.features, 2)])
features = iris.features ./= norm_const
petals = features[!, r"petal"]
sepals = features[!, r"sepal"]

"""A self-organizing map needs to know the square distance between grid points/neurons
which is just given as the Euclidean norm of the indexes that identify a neuron on
grid."""
dsq(i1, i2, j1, j2) = (i1 - i2)^2 + (j1 - j2)^2

"""Self-organizing maps weigh their update rule by some function, which is typically
decreasing with distance from the neuron whose weights are being updated. Here we use
a Gaussian decay centered on the neuron being updated."""
decay(i1, i2, j1, j2, sigma) = exp(-(dsq(i1, i2, j1, j2) / 2sigma))

"""Find the nearest neuron to the given point `x` in the grid `weights`."""
function find_nearest(x::Vector, weights::Array)
    i_nearest = 1
    j_nearest = 1
    shortest_dist = Inf
    for i in axes(weights, 1)
        for j in axes(weights, 2)
            curr_dist = norm(x - weights[i, j, :])
            if curr_dist < shortest_dist
                shortest_dist = curr_dist
                i_nearest = i
                j_nearest = j
            end
        end
    end

    return (i_nearest, j_nearest)
end

"""Do a full pretraining run on the network."""
function train_model(
    dataset::Symbol,
    grid_width::Integer,
    grid_height::Integer;
    lr_stop=0.001,
    max_steps=1_000_000,
    weights_filename="weights.csv",
    montage_filename="training_montage.gif",
)
    # Select what data to train on
    if dataset == :petals
        n_inputs = 2
        data = petals
    elseif dataset == :sepals
        n_inputs = 2
        data = sepals
    elseif dataset == :all
        n_inputs = 4
        data = DataFrame([sepals petals])
    else
        error("Invalid data type. Must be :petals, :sepals or :all")
    end

    # Initial state of training. Weights are initialized to a uniform distribution
    # between 0 and 1.
    Random.seed!(123)
    weights = rand(grid_width, grid_height, n_inputs)
    measurements = size(data, 1)
    lr = 0.2
    sigma = 16
    step = 1

    # Initialize the data for the training montage
    montage = Animation()
    p_lengths = [
        setosa.petallength,
        versi.petallength,
        virgi.petallength,
    ]
    p_widths = [
        setosa.petalwidth,
        versi.petalwidth,
        virgi.petalwidth,
    ]
    s_lengths = [
        setosa.sepallength,
        versi.sepallength,
        virgi.sepallength,
    ]
    s_widths = [
        setosa.sepalwidth,
        versi.sepalwidth,
        virgi.sepalwidth,
    ]

    # Stop training after max steps or when the LR has gotten small enough
    while step <= max_steps && lr > lr_stop
        # Pick random training sample every step
        training_data = Vector(data[rand(1:measurements), :])
        i_nearest, j_nearest = find_nearest(training_data, weights)

        # Update rule is Δw = ε * θ * (x - w), where
        # - ε is the learning rate
        # - θ is the distance decay function
        # - x is the sampled training data vector for the current step
        # - w is the weights vector for the neuron most similar to the data
        for i in axes(weights, 1)
            for j in axes(weights, 2)
                weights[i, j, :] .+= lr *
                                     decay(i, i_nearest, j, j_nearest, sigma) *
                                     (training_data - weights[i, j, :])
            end
        end

        # Reduce LR and decay sigma every 100 steps
        if step % 100 == 0
            lr = 0.995lr
            sigma = 0.98sigma
        end

        # Bonus: Take a snapshot of the state every 1000 steps for visualization
        # Only works when the dataset is two-dimensional because I haven't figured
        # out four-dimensional plotting yet
        if (step == 1 || step % 1000 == 0)
            println("Step $step. LR: $lr. Decay sigma: $sigma")

            if n_inputs == 2
                lengths, widths = [], []
                for i in axes(weights, 1)
                    for j in axes(weights, 2)
                        # Add round(..., digits=1) on the next two values to make the neurons snap to a grid
                        l = weights[i, j, 1] * norm_const
                        w = weights[i, j, 2] * norm_const
                        push!(lengths, l)
                        push!(widths, w)
                    end
                end

                if dataset == :petals
                    object = "Petal"
                    xlims = (0.9, 7.1)
                    ylims = (0, 2.6)
                    data_lengths = p_lengths
                    data_widths = p_widths
                else
                    object = "Sepal"
                    xlims = (4.0, 8.0)
                    ylims = (1.9, 4.6)
                    data_lengths = s_lengths
                    data_widths = s_widths
                end

                frame(
                    montage,
                    scatter(
                        [data_lengths..., lengths],
                        [data_widths..., widths],
                        label=["Setosa" "Versicolor" "Virginica" "Network"],
                        marker=[:square :diamond :hexagon :o],
                        alpha=[0.5 0.5 0.5 1],
                        xlabel="$object length [cm]",
                        ylabel="$object width [cm]",
                        xlims=xlims,
                        ylims=ylims,
                        legend=true,
                    ),
                )
            end
        end

        step += 1
    end

    # Drop the montage as a gif
    if n_inputs == 2
        gif(montage, "plots/$montage_filename", fps=10)
    end

    # weight_magnitudes = [norm(weights[i, j, :]) for i in axes(weights, 1), j in axes(weights, 2)]
    # p = plot(
    #     heatmap(weight_magnitudes),
    #     plot_umatrix(weights),
    #     layout=(1, 2),
    #     legend=false,
    #     size=(1000, 400),
    #     title=["Magnitude of weights" "U-Matrix"],
    # )
    # display(p)

    # Drop the weights as a simple CSV
    weights_df = DataFrame()
    for i in axes(weights, 1)
        for j in axes(weights, 2)
            weights_df[!, "$i-$j"] = weights[i, j, :]
        end
    end

    CSV.write("data/$weights_filename", weights_df)
end

# Train a handful of toy models
train_model(:petals, 8, 8; weights_filename="petals_model_8x8.csv", montage_filename="training_montage_petals_8x8.gif")
train_model(:petals, 16, 16; weights_filename="petals_model_16x16.csv", montage_filename="training_montage_petals_16x16.gif")
train_model(:sepals, 8, 8; weights_filename="sepals_model_8x8.csv", montage_filename="training_montage_sepals_8x8.gif")
train_model(:sepals, 16, 16; weights_filename="sepals_model_16x16.csv", montage_filename="training_montage_sepals_16x16.gif")
train_model(:all, 50, 50; weights_filename="full_model_50x50.csv")
