class_name Charge
extends Node3D

@export var momentum := Vector3(0.0, 0.0, 0.0)
@export var acceleration := Vector3(0.0, 0.0, 0.0)
@export var mass := 1.0#kg
@export var charge := 1.0#C
@export var power := 0.0#W

@export var rad_mesh_resolution := 16

@onready var rad_mesh := $RadiationMesh as MeshInstance3D

func update_rad_mesh(C: float) -> void:
	# Grab radiation mesh data
	var arrays := SphereMesh.new().get_mesh_arrays()
	var vertices := arrays[Mesh.ARRAY_VERTEX].duplicate() as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL].duplicate() as PackedVector3Array
	var indexes := arrays[Mesh.ARRAY_INDEX].duplicate() as PackedInt32Array
	
	# Calculate radiation intensity
	var max_intensity := 0.0
	var intensities: Array[float] = []
	
	for i in vertices.size():
		# Liénard generalization for point charge radiation
		# dP/dΩ ~ |n × (u × a)|² / (n · u)^5
		# where n is the unit vector from the observer to the charge and u = c*n - v
		var n := vertices[i].normalized() # Observation direction based on vertex position
		var u := C * n - momentum / mass
		var rad_intensity := n.cross(u.cross(acceleration)).length_squared() / (n.dot(u) ** 5)
		intensities.append(rad_intensity)
		max_intensity = maxf(max_intensity, rad_intensity)
	
	# Scale based on normalized intensity values
	var scale_factor := 5.0
	var scalings: Array = intensities.map(
		func(inten: float) -> float: return inten / max_intensity * scale_factor
	)
	
	# Transform mesh based on physical values
	for i in vertices.size():
		if scalings[i] > 0.01:
			vertices[i] *= scalings[i]
		else:
			vertices[i] = Vector3(0, 0, 0)
	
	# Create new surface arrays
	var new_arrays := []
	new_arrays.resize(Mesh.ARRAY_MAX)
	new_arrays[Mesh.ARRAY_VERTEX] = vertices
	new_arrays[Mesh.ARRAY_NORMAL] = normals
	new_arrays[Mesh.ARRAY_INDEX] = indexes
	
	# Update mesh
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arrays)
	rad_mesh.mesh = array_mesh
