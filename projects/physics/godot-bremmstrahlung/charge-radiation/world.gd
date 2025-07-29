extends Node3D

@export var g := 9.81#m/s^2
@export var L := 10.0#m
@export var F0 := 10.0#N
@export var C := 3e8#m/s

@onready var charge := $Charge as Charge


const MU0 := PI * 4e-7#N/A^2

func _ready() -> void:
	charge.position = Vector3(-14.0, 0.0, 0.0)


func _physics_process(delta: float) -> void:
	var new := runge_kutta_4(charge.position, charge.momentum, deriv, delta)
	charge.position = new[0]
	charge.momentum = new[1]
	charge.acceleration = get_force(charge.position) / charge.mass
	# Power radiated with Larmor formula
	charge.power = MU0 * charge.charge ** 2 * charge.acceleration.length_squared() / (6 * PI * C)
	#print(charge.power * 1e16, " W")
	charge.update_rad_mesh(C)


func runge_kutta_4(pos: Vector3, mom: Vector3, deriv: Callable, delta: float) -> Array[Vector3]:
	var x1 = deriv.call(pos, mom)
	var k1 = [x1[0] * delta, x1[1] * delta]
	
	var x2 = deriv.call(pos + 0.5 * k1[0], mom + 0.5 * k1[1])
	var k2 = [x2[0] * delta, x2[1] * delta]
	
	var x3 = deriv.call(pos + 0.5 * k2[0], mom + 0.5 * k2[1])
	var k3 = [x3[0] * delta, x3[1] * delta]
	
	var x4 = deriv.call(pos + k3[0], mom + k3[1])
	var k4 = [x4[0] * delta, x4[1] * delta]
	
	return [
		pos + (1.0 / 6.0) * (k1[0] + 2.0 * k2[0] + 2.0 * k3[0] + k4[0]),
		mom + (1.0 / 6.0) * (k1[1] + 2.0 * k2[1] + 2.0 * k3[1] + k4[1])
	]


func deriv(pos: Vector3, mom: Vector3) -> Array[Vector3]:
	return [mom / charge.mass, get_force(pos)]


func get_force(pos: Vector3) -> Vector3:
	if absf(pos.x) <= L:
		return -signf(pos.x) * F0 * Vector3.RIGHT
	else:
		return Vector3.ZERO
