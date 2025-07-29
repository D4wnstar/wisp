extends Node2D

const cell_scene := preload("res://cell.tscn")

@export var columns := 36
@export var rows := 36
@export var step_every := 0.5#seconds

## A boolean matrix representing the starting state of the universe.
var world_seed := [
	[1, 1, 1, 1, 1, 1, 0, 1, 1],
	[1, 1, 1, 1, 1, 1, 0, 1, 1],
	[0, 0, 0, 0, 0, 0, 0, 1, 1],
	[1, 1, 0, 0, 0, 0, 0, 1, 1],
	[1, 1, 0, 0, 0, 0, 0, 1, 1],
	[1, 1, 0, 0, 0, 0, 0, 1, 1],
	[1, 1, 0, 0, 0, 0, 0, 0, 0],
	[1, 1, 0, 1, 1, 1, 1, 1, 1],
	[1, 1, 0, 1, 1, 1, 1, 1, 1],
]

## An integer offset from the top left to determine the positioning of the seed.
## Default is centered.
@export var seed_offset := Vector2i(
	(rows - world_seed.size()) / 2, (columns - world_seed[0].size()) / 2
)

var grid := []
var step_timer := 0.0#seconds

func _ready() -> void:
	# Initialize the matrix
	grid.resize(rows)
	for i in rows:
		grid[i] = []
		grid[i].resize(columns)
	
	var offset := Vector2(0.0, 0.0)
	for row in rows:
		for col in columns:
			# Instantiate a cell and place it into the world
			var cell := cell_scene.instantiate() as Cell
			var seed_row := row - seed_offset.x
			var seed_col := col - seed_offset.y
			if (
				seed_row >= 0 and seed_row <= world_seed.size() - 1
				and seed_col >= 0 and seed_col <= world_seed[0].size() - 1
			):
				cell.live = bool(world_seed[seed_row][seed_col])
			
			cell.position += offset
			add_child(cell)
			
			# Add cell to the grid for later reference
			grid[row][col] = cell
			
			# Calculate offset for the next cell
			if col == columns - 1:
				offset.x = 0.0
				offset.y += Cell.width
			else:
				offset.x += Cell.width


func _process(delta: float) -> void:
	step_timer += delta
	if step_timer >= step_every:
		step_timer = 0.0
		tick()


func tick() -> void:
	# First pass: compute next state
	for row in rows:
		for col in columns:
			var cell := grid[row][col] as Cell
			
			# Count how many cells are alive around the current one
			var alive_neighbors := 0
			for row_offset: int in [-1, 0, 1]:
				for col_offset: int in [-1, 0, 1]:
					if row_offset == 0 and col_offset == 0: continue
					# Use periodic boundary conditions
					var new_row := (row + row_offset) % rows
					var new_col := (col + col_offset) % columns
					var other_cell := grid[new_row][new_col] as Cell
					if other_cell.live: alive_neighbors += 1
			
			cell.alive_neighbors = alive_neighbors

	# Second pass: update the states
	for row in rows:
		for col in columns:
			var cell := grid[row][col] as Cell
			cell.update_state()
