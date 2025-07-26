using LinearAlgebra
using Plots
using PlotThemes

theme(:dracula)

include("common.jl")

function minkowski_segmenter(seg::Segment)::Chain
    seg_length = norm(seg)
    direction = (seg.finish - seg.start) / seg_length
    step = seg_length / 6

    turtle = Turtle(seg.start, direction)

    v::Vector{Point2{Float64}} = []

    # Production rule is → becomes →↻→↻→↺→↺→↻→→↺→→↺→↻→→↻→↻→↺→↻→↺→↺→↻→↺→↺→→↻→↺→→↻→↺→→↻→↻→↺→↻→↻→↺→↻→↺→↺→→↺→↻→↻→→↻→→↺→↻→↻→↺→↺→
    push!(v, seg.start)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, -π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))
    rotate(turtle, π / 2)
    push!(v, forward(turtle, step))

    return Chain(v)
end

A = Point2(0.0, 0.0)
B = Point2(4.0, 0.0)

box = Chain([A, B])
p = plot(
    draw_fractal(box, minkowski_segmenter, 3),
    aspectratio=1,
    size=(2000, 2000),
    color=:white,
    legend=false,
    framestyle=:none,
    grid=false,
    background_color=:black,
    background_color_inside=:black,
)

savefig(p, "plots/minkowski_island_fancy.png")