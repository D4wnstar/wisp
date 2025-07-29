# Just run all the scripts
println("Running 1D free particle")
include("free_particle_1d.jl")

println("Running 2D free particle")
include("free_particle_2d.jl")

println("Running 1D harmonic oscillator eigenstates")
include("harmonic_oscillator_1d.jl")

println("Running 1D harmonic oscillator time evolution")
include("harmonic_oscillator_1d_time.jl")

println("Done 🎉")