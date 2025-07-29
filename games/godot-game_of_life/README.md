An implementation of Conway's Game of Life in Godot.

If you want to build the project yourself, you'll need [Godot](https://godotengine.org/) installed. This project was made in Godot 4.4.1. Any version 4.x.x after it is probably fine. The fastest way to run the game is to double click on `project.godot` (this should open the project), then press F5. Alternatively, you can open a terminal in this project's folder and run one of the following commands based on your OS:

```bash
# Make sure the `bin` folder exists! If not, create it, e.g. `mkdir bin`
godot --export-release "Windows Desktop" "bin/game_of_life.exe" # If on Windows
godot --export-release "MacOS" "bin/game_of_life.app" # If on MacOS
godot --export-release "Linux" "bin/game_of_life.x86_64" # If on Linux
```

This will compile a release build in the `bin` folder. How to run it depends on the OS. For instance, on Linux, you run the newly generated `bin/game_of_life.sh` or call `bin/game_of_life.x86_64` directly. This project was only tested on Linux.

Project done in July 2025.