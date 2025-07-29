class_name Cell
extends Node2D

static var num_of_cells := 0
static var width := 32

@export_group("Color")
@export var live_color := Color.WHITE
@export var dead_color := Color.BLACK
## If true, cells will be colored based on the number of alive neighbors.
## This creates a diffuse, blurry effect where live cells are not distinguishable from dead cells.
@export var diffuse_color := false

@onready var polygon := $Polygon as Polygon2D
var live := false
var alive_neighbors := 0

func _ready() -> void:
	num_of_cells += 1
	set_color(calculate_color())

func update_state() -> void:
	# Apply game logic
	if live:
		if alive_neighbors < 2:
			# 1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
			live = false
		elif alive_neighbors == 2 or alive_neighbors == 3:
			# 2. Any live cell with two or three live neighbours lives on to the next generation.
			pass
		else:
			# 3. Any live cell with more than three live neighbours dies, as if by overpopulation.
			live = false
	else:
		# 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
		if alive_neighbors == 3:
			live = true
	
	set_color(calculate_color())

func calculate_color() -> Color:
	var new_color: Color
	if diffuse_color:
		new_color = dead_color.lerp(live_color, alive_neighbors / 8.0)
	else:
		new_color = live_color if live else dead_color
	return new_color

func set_color(color: Color) -> void:
	polygon.color = color
