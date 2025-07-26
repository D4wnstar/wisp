# An "island" version of the more type 1 Minkowski curve

using LinearAlgebra
using Plots
using PlotThemes

theme(:dracula)

include("common.jl")

function minkowski_segmenter(seg::Segment)::Chain
    seg_length = norm(seg)
    direction = (seg.finish - seg.start) / seg_length
    step = seg_length / 3

    turtle = Turtle(seg.start, direction)

    # Production rule is → becomes →↺→↻→↻→↺→
    A = seg.start
    B = forward(turtle, step)
    rotate(turtle, π / 2)
    C = forward(turtle, step)
    rotate(turtle, -π / 2)
    D = forward(turtle, step)
    rotate(turtle, -π / 2)
    E = forward(turtle, step)
    rotate(turtle, π / 2)
    F = forward(turtle, step)

    return Chain([A, B, C, D, E, F])
end

# Starting shapes
box = Polygon([
    Point2(0.0, 0.0),
    Point2(4.0, 0.0),
    Point2(4.0, 4.0),
    Point2(0.0, 4.0)
])

diamond = Polygon([
    Point2(0.0, 0.0),
    Point2(2.0, 2.0),
    Point2(4.0, 0.0),
    Point2(2.0, -2.0)
])

for (shape, title) in [(box, "box"), (diamond, "diamond")]
    graphs = [plot(shape, aspectratio=1)]
    titles = ["Starting shape"]
    for i in 1:5
        chain = draw_fractal(shape, minkowski_segmenter, i)
        push!(graphs, plot(chain, aspectratio=1))
        titles = [titles... "Iteration $i"]
    end

    l = @layout [a b; c d; e f]
    p = plot(
        graphs...,
        title=titles,
        layout=l,
        size=(1200, 1500),
        legend=false,
        plot_title="Minkowski Island (Type 1)",
    )

    savefig(p, "plots/minkowski_island_type1_$title.png")
end
