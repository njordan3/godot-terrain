extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_button_down():
	SceneSwitcher.goto_scene("res://scenes/TerrainEditor/TerrainEditor.tscn");
