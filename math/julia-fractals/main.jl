# Just run all the scripts
println("Running Koch snowflakes")
include("koch_curve.jl")

println("Running Minkowski curves")
include("minkowski_curve_type1.jl")
include("minkowski_curve_type2.jl")

println("Running Minkowski islands")
include("minkowski_island_type1.jl")
include("minkowski_island_type1.jl")
include("minkowski_island_fancy.jl")

println("Done 🎉")
