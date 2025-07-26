using LinearAlgebra

using Base: +, -, *, /
using Plots

"""A 2-dimensional vector in Cartesian coordinates."""
mutable struct Point2{T <: AbstractFloat}
	x::T
	y::T
end

# 2D vector algebra
Base.:+(p1::Point2, p2::Point2) = Point2(p1.x + p2.x, p1.y + p2.y)
Base.:-(p::Point2) = Point2(-p.x, -p.y)
Base.:-(p1::Point2, p2::Point2) = Point2(p1.x - p2.x, p1.y - p2.y)
Base.:*(p::Point2, x::T) where {T <: Real} = Point2(p.x * x, p.y * x)
Base.:/(p::Point2, x::T) where {T <: Real} = Point2(p.x / x, p.y / x)
LinearAlgebra.norm(p::Point2) = p.x^2 + p.y^2

# Custom method to directly plot an array of Point2
function Plots.plot(points::Vector{<:Point2}; kwargs...)
	plot([(p.x, p.y) for p in points]; kwargs...)
end

"""A segment between two points."""
struct Segment{T <: AbstractFloat}
	start::Point2{T}
	finish::Point2{T} # end is a reserved keyword
end

function LinearAlgebra.norm(s::Segment)
	sqrt((s.finish.x - s.start.x)^2 + (s.finish.y - s.start.y)^2)
end

"""
A chain made of an arbitrary number of sides. Unlike a `Polygon`, a `Chain` is not
a closed shape and will not link the last and first vertex.
"""
struct Chain{T <: AbstractFloat}
	vertices::Vector{Point2{T}}
end

"""Create a `Chain` by concatenating multiple `Chain`s together."""
function Chain(chains::Vector{Chain})
	vertices = reduce(vcat, [c.vertices for c in chains])
	return Chain(vertices)
end

"""Returns an array of `Segment`s for the given `Chain`."""
function segments(c::Chain)::Vector{Segment}
	segments::Vector{Segment} = []
	for idx in eachindex(c.vertices)
		if idx == 1
			# Chains do not loop over
			continue
		else
			s = Segment(c.vertices[idx-1], c.vertices[idx])
		end
		push!(segments, s)
	end

	return segments
end


# Custom method to directly plot a Chain
Plots.plot(c::Chain; kwargs...) = plot(c.vertices; kwargs...)

"""
A polygon made of an arbitrary number of sides. The last side is considered to be
between the last and first vertex, so that it's a closed shape.
"""
struct Polygon{T <: AbstractFloat}
	vertices::Vector{Point2{T}}
end

"""Create a `Polygon` by concatenating multiple `Chain`s together."""
function Polygon(chains::Vector{Chain})
	vertices = reduce(vcat, [c.vertices for c in chains])
	# Since we are making a polygon from chains, it is assumed that the first and last
	# vertices will be the same, so we pop the last to one avoid duplicates
	pop!(vertices)
	return Polygon(vertices)
end

"""Returns an array of `Segment`s for the given `Polygon`."""
function segments(p::Polygon)::Vector{Segment}
	segments::Vector{Segment} = []
	for idx in eachindex(p.vertices)
		if idx == 1
			# Polygons loop over
			s = Segment(p.vertices[end], p.vertices[1])
		else
			s = Segment(p.vertices[idx-1], p.vertices[idx])
		end
		push!(segments, s)
	end

	return segments
end

# Custom method to directly plot a Polygon
function Plots.plot(p::Polygon; kwargs...)
	# A polygon needs to loop over so we add the first point at the end
	plot([p.vertices..., p.vertices[1]]; kwargs...)
end

"""The cursor for a basic turtle graphics implementation."""
mutable struct Turtle{T <: AbstractFloat}
	pos::Point2{T}
	dir::Point2{T}
end

"""
Moves the turtle forward by the given distance. Modifies in-place.
Returns the new position.
"""
function forward(turtle::Turtle, distance::T) where {T <: AbstractFloat}
	turtle.pos += turtle.dir * distance
end

"""
Rotate the turtle's walking direction by the given angle, counterclockwise. Modifies in-place.
Returns the new direction vector.
"""
function rotate(turtle::Turtle, angle::T) where {T <: AbstractFloat}
	# Rotation is a unitary operation so no need to renormalize dir
	new_x = turtle.dir.x * cos(angle) - turtle.dir.y * sin(angle)
	new_y = turtle.dir.x * sin(angle) + turtle.dir.y * cos(angle)
	turtle.dir.x = new_x
	turtle.dir.y = new_y
	return turtle.dir
end

"""
Draw the n-th iteration of a fractal by modifying each segment of the starting shape according
to `segmenter`. `segmenter` must take a `Segment` as an argument and return a `Chain`.
The signature must look like `segmenter(s::Segment)::Chain`.
"""
function draw_fractal(
	shape::Polygon,
	segmenter::Function,
	iterations::Unsigned=1,
)::Polygon
	if iterations == 0
		return shape
	end

	# Each cycle takes the shape, breaks it down into edges, segments them and
	# reconstructs the new shape
	for _ in 1:iterations
		segs = segments(shape)
		curr_chains::Vector{Chain} = [segmenter(s) for s in segs]
		shape = Polygon(curr_chains)
	end

	return shape
end

function draw_fractal(
	shape::Chain,
	segmenter::Function,
	iterations::Unsigned=1,
)::Chain
	if iterations == 0
		return shape
	end

	for _ in 1:iterations
		segs = segments(shape)
		curr_chains::Vector{Chain} = [segmenter(s) for s in segs]
		shape = Chain(curr_chains)
	end

	return shape
end

draw_fractal(sh, seg, i::Integer) = draw_fractal(sh, seg, unsigned(i))