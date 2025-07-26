Visualization of known diffraction patterns for simple laboratory slits:
- single 1D slit
- double 1D slit
- circular 2D slit
- rectangular 2D slit

The code only visualizes known analytical results, it does not simulate the actual path or wave behavior of light. An additional script is provided to show how one may reverse engineer the shape of a slit from the diffraction pattern by taking the Fourier transform of the pattern.

All the plotted results are under `plots`. Each script can be used individually by running `julia file_name.jl` if you have all necessary packages in the global environment or by opening the REPL using `julia` and running `include("file_name")` if you want to instantiate a new environment. The `main.jl` script just runs every other script.

Project done towards the end of 2023. This project is pretty messy in terms of code quality, so it's not my best work. I leave it here because I still think it's interesting to look at, if nothing else for the physics involved.