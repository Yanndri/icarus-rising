extends Label

func _ready() -> void:
	StarBank.stars_changed.connect(_on_stars_changed)
	_on_stars_changed(StarBank.total_stars)

func _on_stars_changed(total: int) -> void:
	text = "Stars: %d" % total
