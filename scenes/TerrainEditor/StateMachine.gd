extends Node2D
class_name StateMachine


var state = null;
var previous_state = null;
var states = {};
var state_meta = null;

@onready var parent = get_parent();

func _process(delta):
	if state != null:
		_state_logic(delta);
		var transition = _get_transition(delta);
		if transition.state != null:
			set_state(transition.state, transition.meta);

func _physics_process(delta):
	if state != null:
		_physics_state_logic(delta);
		var transition = _get_physics_transition(delta);
		if transition.state != null:
			set_state(transition.state, transition.meta);

func _draw():
	pass;

func _state_logic(_delta):
	pass;

func _get_transition(_delta):
	return { "state": null, "meta": null };
	
func _physics_state_logic(_delta):
	pass;

func _get_physics_transition(_delta):
	return { "state": null, "meta": null };

func _enter_state(_new_state, _old_state):
	pass;
	
func _exit_state(_new_state, _old_state):
	pass;

func _allow_set_state(_new_state, _old_state) -> bool:
	return true;

func set_state(new_state, new_meta = null):
	if _allow_set_state(new_state, state):
		previous_state = state;
		state = new_state;
		state_meta = new_meta;
		if previous_state != null:
			_exit_state(new_state, previous_state);
		if new_state != null:
			_enter_state(new_state, previous_state);

func add_state(state_name: String):
	states[state_name] = states.size();
