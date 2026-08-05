extends Node3D
## Duplicates StarTemplate around the 3D scene.

@export var copies_per_star := 4
@export_node_path("MeshInstance3D") var spawn_box_path: NodePath = ^"SpawnBox"
@export var scatter_min := Vector3(-20.0, -12.0, -40.0)
@export var scatter_max := Vector3(20.0, 12.0, -2.0)
@export var randomize_rotation := true

var _random := RandomNumberGenerator.new()
var _spawn_box: MeshInstance3D


func _ready() -> void:
	_random.randomize()
	_spawn_box = get_node_or_null(spawn_box_path) as MeshInstance3D
	var template := get_node_or_null("StarTemplate") as Node3D
	if template == null:
		push_warning("StarSpawner is missing its StarTemplate child.")
		return

	template.visible = false
	for copy_index in copies_per_star:
		var copy := template.duplicate() as Node3D
		copy.name = "%s_Copy%d" % [template.name, copy_index + 1]
		copy.visible = true
		add_child(copy)
		_randomize_star(copy)


func _randomize_star(star: Node3D) -> void:
	if _spawn_box != null and _spawn_box.mesh is BoxMesh:
		var box := _spawn_box.mesh as BoxMesh
		var local_position := Vector3(
			_random.randf_range(-box.size.x * 0.5, box.size.x * 0.5),
			_random.randf_range(-box.size.y * 0.5, box.size.y * 0.5),
			_random.randf_range(-box.size.z * 0.5, box.size.z * 0.5)
		)
		star.global_position = _spawn_box.global_transform * local_position
	else:
		star.position = Vector3(
			_random.randf_range(scatter_min.x, scatter_max.x),
			_random.randf_range(scatter_min.y, scatter_max.y),
			_random.randf_range(scatter_min.z, scatter_max.z)
		)
	if randomize_rotation:
		star.rotation = Vector3(
			_random.randf_range(0.0, TAU),
			_random.randf_range(0.0, TAU),
			_random.randf_range(0.0, TAU)
		)
