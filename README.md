# WISP ✨
WISP is a collection of many standalone programming projects on the topic of scientific computing, videogames and simulations. The name stands for `(The) World Is a Simulation, Probably`.

WISP is a monorepo, meaning it's a collection of repositories that are independent of one another and stored in the same place for organization and convenience. Each repository represents an individual project and they are categorized by field using the top-level folders so that they are easy to browse. Furthermore, this codebase is highly polyglot, with several languages being used across based largely on what I felt like learning at the time of writing the code. You can see the language breakdown on the GitHub page for an updated distribution. To make it clear what each project uses, the folders all follow the same naming convention of `field/language-name_of_project`. For instance, `math/julia-fractals`.

## Why?
To be honest, there isn't a long and complicated answer for this. I just think programming is *fun*. Sure, sometimes it's a confusing mess filled with questionable decisions (looking at you, web development), but other times it's creating entire worlds from scratch with just words and magic electricity boards. It really comes down to what you do with it.

WISP is a collection of things I did for fun. I am a person that plans far into the future, so these works are pieces of a "grand plan" per say, but I don't work on them because I *need* to. I do so because I *want* to. As such, these projects span a lot of different fields, because I am a person that likes a lot of different things. The one thing all of these projects have in common is that they are largely one-and-done curiosities; larger projects have their own identity and repository.

## Browsing
I make an effort to make all of these projects understandable even without running any code yourself. This generally means producing images and animations showing the end result of the project and adding them to the repo. Most projects carry a `gallery` or `plots` folder that you can peruse to see what's going on without needing to build any code yourself.

## Building
Handling distribution on a polyglot codebase is a pain and it's even worse in monorepo where each project has its own dependencies. As such, you will not find precompiled binaries for these projects. This is expected for interpreted languages, but can be annoying for compiled ones. I attempt to have the same code structure for all projects of the same language however. You can follow the guidelines below to run the projects.

> [!tip] Tip
> Since each project is considered to be an indipendent repository, you should always work on them while in their root folder. Trying to run a project from somewhere else is a recipe for disaster, mostly due to relative paths. Please `cd` into a project folder before running any of its script. All the following information assumes that you did.

> [!warning] Warning
> I do the grand majority of my programming on Linux, so I can't guarantee that these projects will run perfectly on other operating systems. This is mostly relevant for anything with graphical rendering, which can work change a lot from OS to OS.

### Julia
Julia is a JIT-compiled language, meaning it requires no compilation. Each Julia project provides a `Project.toml` and `Manifest.toml` that contain the dependencies. It's recommended you always create a new virtual environment for each project. Open the REPL with `julia`, enter PKG mode by pressing `]`, then run `activate .`. This will create a new environment in the project folder. Run `instantiate` to download all packages. Then, while in the REPL, you can run individual scripts by importing their code with `include("script_name.jl")`. Alternatively, outside of the REPL, you can run `julia --project script_name.jl`, though using the REPL is much faster since it caches compilation.

### Rust
Rust is a compiled language. Each Rust project provides a `Cargo.toml` and `Cargo.lock` that contain the dependencies. While in the same folder as these (or at most a subfolder), run `cargo run` to compiled a dev build. Run `cargo build` to compile an optimized release build.

I rely a lot on the [Bevy](https://bevy.org/) game engine for these projects in order to have an interactive real-time process with a rendering backbone. Bevy is still early in development and doesn't have a graphical editor, but that's almost a positive in this case, since it feels like just another programming library instead of a separate piece of software like other engines.

> [!warning] Bevy
> A note of warning: Bevy is pretty demanding on compilation time (even for Rust standards...) so beware of long compile times. The [quick start guide](https://bevy.org/learn/quick-start/introduction/) has tips for faster compilation. Also, the compilation artefacts can be quite hefty for such a large library: I've seen the `target` folder get into the ~20 GiB range just by tinkering with the gas simulation project, not to mention a 1 GiB debug executables.

### Godot
[Godot](https://godotengine.org/) is an open-source cross-platform game engine. It is a great piece of software that I recommend to anyone wanting to make videogames or demanding GUI application. Unlike Bevy, Godot is much more mature and is a separate piece of software, so publishing and compiling code is a bit more involved.

#### Web editor
The easiest way is to use the [web editor](https://editor.godotengine.org/). This is a copy of Godot that runs in your browser, so you don't need to install anything. In order to run a project, go under `extras/godot-project-zips` and find the ZIP file corresponding to the project your interested in. In the web editor, select it under `Preload project ZIP`. Then, click `Start Godot editor`. Wait a while (possibly even a minute) while it loads (performance is worse on Firefox than Chromium browsers). When it loads, give the project a name and `Install`. If it tells you that some features are unsupported, just click `OK`. When it opens, press F5 or the play button in the top right and the game should run a debug build in your browser.

#### Native
Installing Godot gives you a much better experience, since browsers can be pretty unreliable. If you have Godot installed, double click on the `project.godot` in the project folder and it should automatically open. Then press F5 or the play button and it will run the debug build natively in your OS.

To compile the code, you'll need *export templates*. You can download them from [here](https://godotengine.org/download) (look for "Export templates"). Once downloaded, go under `Editor > Manage Export Templates` from the top menu, click `Install from file` and select the ZIP file you downloaded. Then, go under `Project > Export...`, click `Add...` at the top and select the profile for your operating system. MacOS will probably complain about something; just follow the instructions. Finally, click `Export project` to actually compile. The output depends on the operating system. For instance, on Linux you get an executable and shell script that you can run.

## License
All code in this repository is released under the MIT license. An individual project might be released under a different license, in which case that license takes precedence for that project only.