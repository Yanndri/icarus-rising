extends Node2D
## Spawns a randomized pair of sprites for every texture in Assets/Stars.

const STAR_SCENE := preload("res://Scenes/star.tscn")
@export var NEXT_LEVEL_SCENE : PackedScene = preload("res://Scenes/next_level.tscn")

@export_dir var stars_directory := "res://Assets/Stars"
@export var stars_per_texture := 2
@export var spawn_area := Rect2(0.0, 0.0, 1280.0, 720.0)
@export var drag_bounds := Rect2(10.0, 10.0, 1260.0, 700.0)
@export var min_scale := 0.5
@export var max_scale := 1.0
@export var randomize_size := true
@export var randomize_rotation := true

var _random := RandomNumberGenerator.new()
var _dragged_star: RigidBody2D
var _drag_offset := Vector2.ZERO
var _level_complete_triggered := false


func _ready() -> void:
	_random.randomize()
	_spawn_stars()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			CursorManager.set_clicking()
			_start_drag(get_global_mouse_position())
		else:
			CursorManager.set_default()
			if _dragged_star != null:
				_dragged_star.freeze = false
			_dragged_star = null
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _dragged_star != null:
		var desired_position := get_global_mouse_position() - _drag_offset
		_dragged_star.global_position = _clamp_star_position(desired_position, _dragged_star)
		get_viewport().set_input_as_handled()

func _spawn_stars() -> void:
	var directory := DirAccess.open(stars_directory)
	if directory == null:
		push_warning("Star spawner could not open: %s" % stars_directory)
		return

	var star_paths: Array[String] = []
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
			star_paths.append(stars_directory.path_join(file_name))
		file_name = directory.get_next()
	directory.list_dir_end()

	star_paths.sort()
	for star_path in star_paths:
		var texture := load(star_path) as Texture2D
		if texture == null:
			push_warning("Star spawner could not load: %s" % star_path)
			continue

		for _i in stars_per_texture:
			_spawn_star(texture)


func _spawn_star(texture: Texture2D) -> void:
	var star := STAR_SCENE.instantiate() as RigidBody2D
	if star == null:
		push_warning("Star spawner could not instantiate the star template.")
		return

	star.name = texture.resource_path.get_file().get_basename()
	star.position = Vector2(
		_random.randf_range(spawn_area.position.x, spawn_area.end.x),
		_random.randf_range(spawn_area.position.y, spawn_area.end.y)
	)
	if randomize_size:
		star.scale = Vector2.ONE * _random.randf_range(min_scale, max_scale)
	if randomize_rotation:
		star.rotation = _random.randf_range(0.0, TAU)

	var visual := star.get_node_or_null("%StarIcon") as Sprite2D
	if visual == null:
		push_warning("Star template is missing a Sprite2D child.")
		star.queue_free()
		return
	visual.texture = texture
	star.body_entered.connect(_on_star_body_entered.bind(star))
	add_child(star)

#Function to check if the closest star is the correct matched star
func _on_star_body_entered(other_body: Node2D, star: RigidBody2D) -> void:
	if not is_instance_valid(star) or star.is_queued_for_deletion():
		return
	var other_star := other_body as RigidBody2D
	if other_star == null or other_star.is_queued_for_deletion():
		return

	var star_visual := star.get_node_or_null("%StarIcon") as Sprite2D
	var other_visual := other_star.get_node_or_null("%StarIcon") as Sprite2D
	if star_visual == null or other_visual == null or star_visual.texture == null or other_visual.texture == null:
		return
	if star_visual.texture.resource_path != other_visual.texture.resource_path:
		return

	star.queue_free()
	other_star.queue_free()
	call_deferred("_check_level_complete")


func _check_level_complete() -> void:
	if _level_complete_triggered:
		return
	for child in get_children():
		if child is RigidBody2D and not child.is_queued_for_deletion():
			return

	print("LEVEL COMPLETE")
	_level_complete_triggered = true
	get_tree().change_scene_to_packed(NEXT_LEVEL_SCENE)


func _start_drag(mouse_position: Vector2) -> void:
	var stars := get_children()
	for index in range(stars.size() - 1, -1, -1):
		var star := stars[index] as RigidBody2D
		if star == null:
			continue

		var local_mouse_position := star.to_local(mouse_position)
		var visual := star.get_node_or_null("%StarIcon") as Sprite2D
		if visual == null or visual.texture == null:
			continue
		var texture_rect := Rect2(-visual.texture.get_size() * 0.5, visual.texture.get_size())
		if texture_rect.has_point(local_mouse_position):
			_dragged_star = star
			_drag_offset = mouse_position - star.global_position
			star.z_index = 1000
			star.freeze = true
			star.linear_velocity = Vector2.ZERO
			star.angular_velocity = 0.0
			return


func _clamp_star_position(desired_position: Vector2, star: RigidBody2D) -> Vector2:
	var collision_shape := star.get_node_or_null("%CollisionShape2D") as CollisionShape2D
	var rectangle := collision_shape.shape as RectangleShape2D if collision_shape != null else null
	if rectangle == null:
		return desired_position

	var half_size := rectangle.size * 0.5 * star.scale
	var rotation_sine := absf(sin(star.rotation))
	var rotation_cosine := absf(cos(star.rotation))
	var horizontal_extent := half_size.x * rotation_cosine + half_size.y * rotation_sine
	var vertical_extent := half_size.x * rotation_sine + half_size.y * rotation_cosine

	return Vector2(
		clampf(desired_position.x, drag_bounds.position.x + horizontal_extent, drag_bounds.end.x - horizontal_extent),
		clampf(desired_position.y, drag_bounds.position.y + vertical_extent, drag_bounds.end.y - vertical_extent)
	)
