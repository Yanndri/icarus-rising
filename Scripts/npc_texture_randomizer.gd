extends CanvasGroup
## Randomizes each NPC Sprite2D from the texture folder matching its part name.

@export var randomize_on_ready := true

@export_category("Available NPC Textures")
@export var torso_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Torsos/torso1.png")]
@export var hair_textures: Array[Texture2D] = [
	preload("res://Assets/NPCTextures/Hairs/hair1.png"),
	preload("res://Assets/NPCTextures/Hairs/hair2.png"),
	preload("res://Assets/NPCTextures/Hairs/hair3.png"),
]
@export var head_textures: Array[Texture2D] = [
	preload("res://Assets/NPCTextures/Heads/head1.png"),
	preload("res://Assets/NPCTextures/Heads/head2.png"),
	preload("res://Assets/NPCTextures/Heads/head3.png"),
	preload("res://Assets/NPCTextures/Heads/head4.png"),
]
@export var nose_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Noses/Nose1.png")]
@export var eye_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Eyes/eyes1.png")]
@export var mouth_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Mouths/mouth1.png")]
@export var table_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Tables/GoedWareTable1.png")]
@export var hand_textures: Array[Texture2D] = [preload("res://Assets/NPCTextures/Hands/hand1.png")]

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	if randomize_on_ready:
		randomize_textures()


func randomize_textures() -> void:
	var shared_skin_color := _random_color()
	for child in get_children():
		var sprite := child as Sprite2D
		if sprite == null:
			continue

		var available_textures: Array[Texture2D] = _textures_for_part(sprite.name)
		if available_textures.is_empty():
			continue

		sprite.texture = available_textures[_random.randi_range(0, available_textures.size() - 1)]
		var replacement_color := shared_skin_color if sprite.name in ["Head", "Hand", "Torso"] else _random_color()
		_randomize_replacement_color(sprite, replacement_color)


func _randomize_replacement_color(sprite: Sprite2D, replacement_color: Color) -> void:
	var shader_material := sprite.material as ShaderMaterial
	if shader_material == null:
		return

	# Give this sprite its own material so shared materials do not change together.
	shader_material = shader_material.duplicate() as ShaderMaterial
	sprite.material = shader_material
	shader_material.set_shader_parameter("replacement_color", replacement_color)


func _random_color() -> Color:
	return Color(_random.randf(), _random.randf(), _random.randf(), 1.0)


func _textures_for_part(part_name: String) -> Array[Texture2D]:
	match part_name:
		"Torso": return torso_textures
		"Hair": return hair_textures
		"Head": return head_textures
		"Nose": return nose_textures
		"Eyes": return eye_textures
		"Mouth": return mouth_textures
		"Table": return table_textures
		"Hand": return hand_textures
		_: return []
