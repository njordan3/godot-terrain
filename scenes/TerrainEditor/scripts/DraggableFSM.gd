extends StateMachine


signal on_selected(draggable, new_state_meta);

# The 'selected' and 'dialogue_open' states need an intermediate 'closing' state
# because they are only supposed to 'close' under specific circumstances.

# 'selected' only 'closes' when the left mouse button is lifted
# 'dialogue_open' only 'closes' when the left mouse button is pressed 

func _ready():
	add_state("idle");
	add_state("highlighted");
	add_state("selected");
	add_state("unselected");
	add_state("dialogue_open");
	add_state("dialogue_close");
	call_deferred("set_state", states.idle);

func _draw():
	var sprite = parent.get_node("Sprite");
	if sprite:
		match state:
			states.selected, states.dialogue_open:
				draw_rect(Rect2(Vector2.ZERO, sprite.texture.get_size()), Color.AQUA, false);
			states.highlighted:
				draw_rect(Rect2(Vector2.ZERO, sprite.texture.get_size()), Color.WHITE, false);

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			if state == states.dialogue_open:
				call_deferred("set_state", states.dialogue_close);
			elif state == states.selected:
				call_deferred("set_state", states.unselected);

func _state_logic(_delta):
	match state:
		states.dialogue_close, states.unselected: # Intermediate 'close' states
			call_deferred("set_state", states.idle);
		states.dialogue_open:
			if state_meta != null && state_meta.pos:
				$"../PanelContainer".visible = true;
				$"../PanelContainer".position = state_meta.pos;
			else:
				call_deferred("set_state", states.idle);
		states.selected:
			if state_meta != null && state_meta.pos:
				var new_position: Vector2 = get_viewport().get_mouse_position();
				new_position -= state_meta.pos;
				parent.position = new_position;
			else:
				call_deferred("set_state", states.idle);
	
func _exit_state(_new_state, old_state):
	match old_state:
		states.dialogue_open:
			$"../PanelContainer".visible = false;
			$"../PanelContainer".position = Vector2.ZERO;
	queue_redraw();

func _allow_set_state(new_state, old_state) -> bool:
	# Check for intermediate closing states
	if old_state == states.dialogue_open && new_state != states.dialogue_close:
		return false;
	if old_state == states.selected && new_state != states.unselected:
		return false;
	return true;

func is_on_top() -> bool:
	var areas = parent.get_overlapping_areas();
	var result = true;
	for area in areas:
		var fsm = area.get_node("DraggableFSM");
		if fsm && fsm.state == states.highlighted && !is_greater_than(area):
			result = false;
	return result;

func _on_draggable_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# If overlapping other highlighted terrain, move only the top terrain
			if is_on_top():
#				call_deferred("set_state", states.selected, { "pos": to_local(event.position) });
				on_selected.emit(parent, event);
				event.canceled = true;
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if is_on_top():
				call_deferred("set_state", states.dialogue_open, { "pos": event.position });

func _on_draggable_mouse_entered():
	call_deferred("set_state", states.highlighted);

func _on_draggable_mouse_exited():
	call_deferred("set_state", states.idle);
