# TODO: This currently doesn't work.
# The idea is to train a feedforward network that can interpret a the class
# of an input (Setosa, Versicolor, Virginica) based on the compressed data of the
# SOM instead of the original. This way the feedforward is 2 dims in, 1 categorical
# variable out, instead of 4 dims in.
function train_predictor(; quiet=false)
    n = 2
    ϵ = 0.2
    E_stop = 10^-3
    max_iter = 100_000

    examples = hcat(total_x, total_y)
    norm_const = maximum(examples)
    examples = 2 * (examples ./ norm_const) .- 1
    #              Setosa = 1   Versicolor = 0 Virginica = -1
    results = vcat(fill(1, 50), fill(0, 50), fill(-1, 50))

    yarr = rand((-1, 1)) * rand(length(results))
    w = rand((-1, 1)) * rand(n)

    cycle = 0
    while cycle < max_iter
        ν = rand(1:length(results))
        x_ν = examples[ν, :]
        y = tanh(x_ν ⋅ w)
        yarr[ν] = y

        δ = results[ν] - y
        w += ϵ * δ * (1 - tanh(y)^2) * x_ν

        E = 0.5 * sum([(ξ_ν - y_ν)^2 for (ξ_ν, y_ν) in zip(results, yarr)])
        if cycle % 1000 == 0 && !quiet
            println("Cycle $cycle. Error: $E")
        end
        if E < E_stop
            break
        end
        cycle += 1
    end

    return w
end

classify(x::Vector{Tuple{Any,Any}}, w::Vector) = [classify(x_i, w) for x_i in x]
classify(x::Vector{Vector}, w::Vector) = [classify(x_i, w) for x_i in x]
classify(x::Tuple, w::Vector) = classify(collect(x), w)
function classify(x::Vector, w::Vector)
    y = tanh(x ⋅ w)

    d1 = abs(1 - y)
    d2 = abs(y)
    d3 = abs(-1 - y)
    if d1 < d2 && d1 < d3
        return "Iris Setosa"
    elseif d2 < d1 && d2 < d3
        return "Iris Versicolor"
    elseif d3 < d1 && d3 < d2
        return "Iris Virginica"
    end
end
