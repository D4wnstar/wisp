using LinearAlgebra
using Plots
using PlotThemes

using Base: +, -, *, /

theme(:dracula)

include("common.jl")

function koch_segmenter(seg::Segment, antiflake=false)::Chain
    spin = antiflake ? -1 : 1
    seg_length = norm(seg)
    direction = (seg.finish - seg.start) / seg_length
    step = seg_length / 3

    turtle = Turtle(seg.start, direction)

    # Production rule is → becomes →↺→↻↻→↺→
    A = seg.start
    B = forward(turtle, step)
    rotate(turtle, spin * π / 3)
    C = forward(turtle, step)
    rotate(turtle, spin * -2π / 3)
    D = forward(turtle, step)
    rotate(turtle, spin * π / 3)
    E = forward(turtle, step)

    return Chain([A, B, C, D, E])
end

A = Point2(0.0, 0.0)
B = Point2(0.5, sqrt(3) / 2)
C = Point2(1.0, 0.0)

for (title, flag) in [("Snowflake", false), ("Antiflake", true)]
    triangle = Polygon([A, B, C])
    graphs = [plot(triangle, aspectratio=1)]
    titles = ["Starting shape"]

    for i in 1:5
        poly = draw_fractal(triangle, s -> koch_segmenter(s, flag), i)
        push!(graphs, plot(poly, aspectratio=1))
        titles = [titles... "Iteration $i"]
    end

    l = @layout [a b; c d; e f]
    p = plot(
        graphs...,
        title=titles,
        layout=l,
        size=(1000, 1500),
        legend=false,
        plot_title="Koch $title",
    )

    lower = lowercase(title)
    savefig(p, "plots/koch_$lower.png")
end