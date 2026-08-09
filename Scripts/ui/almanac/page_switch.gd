extends TextureButton

@export var target_tab_container: NodePath
@export var tab_index: int = 0

@onready var _tab_container: TabContainer = get_node(target_tab_container)


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	_tab_container.current_tab = tab_index
