# Just run all the scripts
println("Running single slit 1D")
include("single_slit_1d.jl")

println("Running double slit 1D")
include("double_slit_1d.jl")

println("Running circle slit 2D")
include("single_circ_slit_2d.jl")

println("Running rectangle slit 2D")
include("single_rect_slit_2d.jl")

println("Running Fourier transform of wave packet")
include("fourier_analysis.jl")

println("Running Fourier transform of diffraction patterns")
include("slit_reverse_engineering.jl")

println("Done 🎉")