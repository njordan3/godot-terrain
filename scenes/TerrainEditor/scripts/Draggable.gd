extends Area2D
class_name Draggable


signal on_selected(draggable, event);

var selected_position: Vector2;
var dialogue_position: Vector2;

var state = {
	"selected": false,
	"highlighted": false,
	"area_highlighted": false,
	"dialogue_open": false,
};

func set_state(field: String, value: bool):
	state[field] = value;
	match field:
		"highlighted", "area_highlighted":
			var other_field = "area_highlighted";
			if field == other_field:
				other_field = "highlighted";
			if value:
				add_to_group("highlighted");
			elif !state[other_field]:
				remove_from_group("highlighted");
	queue_redraw();

func is_state(check_state: String) -> bool:
	return state[check_state];

func _ready():
	pass;

func _draw():
	if state.selected || state.dialogue_open:
		draw_rect(Rect2(Vector2.ZERO, $Sprite.texture.get_size()), Color.AQUA, false);
	elif state.highlighted || state.area_highlighted:
		draw_rect(Rect2(Vector2.ZERO, $Sprite.texture.get_size()), Color.WHITE, false);

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !event.pressed:
				if state.dialogue_open:
					set_state("dialogue_open", false);
				elif state.selected:
					set_state("selected", false);
			elif !state.highlighted && state.area_highlighted:
				# If it's highlighted then we can assume the mouse was clicked on draggable node
				var area_highlighted_dragging = false;
				for highlighted in get_tree().get_nodes_in_group("highlighted"):
					if highlighted is Draggable && highlighted.is_state("area_highlighted") && highlighted.is_state("highlighted"):
						area_highlighted_dragging = true;
						break;

				if !area_highlighted_dragging:
					set_state("area_highlighted", false);

func _process(_delta):
	if state.selected:
		var new_position: Vector2 = get_viewport().get_mouse_position();
		new_position -= selected_position;
		position = new_position;
	if state.dialogue_open:
		$PanelContainer.visible = true;
		$PanelContainer.position = dialogue_position;

func is_on_top() -> bool:
	var areas = get_overlapping_areas();
	var result = true;
	for area in areas:
		if area is Draggable && area.is_state("highlighted") && !is_greater_than(area):
			result = false;
	return result;

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# If overlapping other highlighted terrain, move only the top terrain
			if is_on_top():
				print("cancel");
				on_selected.emit(self, event);
				event.canceled = true;
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_on_top():
				set_state("dialogue_open", true);
				dialogue_position = event.position;

func _on_mouse_entered():
	set_state("highlighted", true);

func _on_mouse_exited():
	
	set_state("highlighted", false);

# Use 'button_down' because it gets processed before 'pressed'
func _on_delete_button_button_down():
	queue_free();
