A real-time simulation of a classical monatomic gas in two dimensions using hard discs with perfectly elastic collisions. Realistic numbers are used throughout the simulation in an effort to analyze an actual physical system.

The simulation consists of an unbreakable rigid box in which a certain small number of particles (rigid discs) are initally set in an arbitrary formation. The particles are then given a random velocity and let loose. These particles collide whenever they overlap and the collision is taken to be perfectly elastic, meaning no kinetic energy is lost. The same goes for any collision with the walls. These leads to a conservative system that matches the basic ideas of kinetic gas theory.

Numerically, the particles are chosen to be helium-4 atoms ($^{4}\text{He}$), with a mass of $4.002\text{ u}$, where $\text{u}\equiv1.660\times 10^{-27}\text{ kg}$ is the atomic unit. All atoms are initialized with the same speed, which is chosen to be the average speed of helium-4 at $T=293\text{ K}$, as given by the equipartition theorem. It comes out to be $v=1103.3\text{ m/s}$. The velocity vector is given a random direction. The box is given dimensions of $1000\text{ m}\times 700\text{ m}$ and 400 particles are placed in it, making for a *very* rarefied gas. The small number is due to ease of visualization and performance reasons. The physical size of the particles is completely arbitrary and chosen largely for aesthetic purposes, as showing Angstrom-sized discs would be unreasonable. Entropy is also calculated from the starting conditions using the Sackur-Tetrode equation, representing the entropy of the gas after the initial transient where the particles rearrange themselves randomly in the box.

The speeds of the particles are displayed each frame in a histogram, over which the two-dimensional Maxwell-Boltzmann distribution is drawn. The simulation shows how the histogram bins hover around the theoretical distribution, as we expect.

The simulation has some barebones commands:
- Left and drag to move the camera
- Mouse wheel to zoom
- Spacebar to pause resume the simulation
- Up/Down arrow keys to simulate in slow motion (achieved by dividing the timestep by the slow motion value)

The `gallery` folder has a video of the simulation. In case you want to compile the project yourself, open a terminal in this folder and then do `cargo run` or `cargo build` (assuming you have Rust installed). This project is developed in Rust using the [Bevy game engine](https://bevy.org/) (version 0.15). Be aware that compiling the Bevy libraries will take a while and will probably take up several gigabytes of disk space for the compilation artifacts.

Project done in December 2024.