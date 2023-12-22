extends Area2D
class_name Draggable

signal on_selected(terrain);

var highlighted: bool = false;
var selected: bool = false;
var selected_position: Vector2;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if selected:
		var new_position: Vector2 = get_viewport().get_mouse_position();
		new_position -= selected_position;
		position = new_position;

func is_on_top() -> bool:
	var areas = get_overlapping_areas();
	var result = true;
	for area in areas:
		if area.highlighted && !is_greater_than(area):
			result = false;
	return result;

func toggle_highlight():
	highlighted = !highlighted;
	queue_redraw();

func _on_mouse_entered():
	toggle_highlight();

func _on_mouse_exited():
	toggle_highlight();

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			if $PanelContainer.visible:
				$PanelContainer.visible = false;
				$PanelContainer.position = Vector2.ZERO;
			if selected:
				selected = false;
				queue_redraw();

func _on_draw():
	if selected:
		draw_rect(Rect2(Vector2.ZERO, $Sprite.texture.get_size()), Color.AQUA, false);
	elif highlighted:
		draw_rect(Rect2(Vector2.ZERO, $Sprite.texture.get_size()), Color.WHITE, false);

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# If overlapping other highlighted terrain, move only the top terrain
			if is_on_top():
				selected = true;
				selected_position = to_local(event.position);
				on_selected.emit(self);
				event.canceled = true;
				queue_redraw();
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_on_top():
				$PanelContainer.visible = true;
				$PanelContainer.set_position(event.position);

func _on_delete_button_button_down():
	queue_free();
