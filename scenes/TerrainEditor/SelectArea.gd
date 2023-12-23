extends Area2D
class_name SelectArea;


var init_position: Vector2;
var selecting = false;
@onready var parent = get_parent();

func _ready():
	reset();

func _physics_process(_delta):
	if selecting:
		var areas = get_overlapping_areas();
		for area in areas:
			if area is Draggable:
				area.set_state("area_highlighted", true);

func _draw():
	var light_blue_alpha = Color(0.678431, 0.847059, 0.901961, 0.25);
	draw_rect(Rect2(Vector2.ZERO, $Collision.shape.get_size()), light_blue_alpha, true);

func reset():
	$Collision.shape.size = Vector2.ZERO;
	position = Vector2.ZERO;
	init_position = Vector2.ZERO;
	selecting = false;
	queue_redraw();

func is_terrain_selected() -> bool:
	var terrain_pieces = get_tree().get_nodes_in_group("terrain");
	for terrain in terrain_pieces:
		if terrain.is_state("selected") || terrain.is_state("highlighted"):
			return true;
	return false;

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed && !is_terrain_selected():
				position = event.position;
				init_position = event.position;
				selecting = true;
			else:
				reset();
	if event is InputEventMouseMotion && selecting:
		var size = (init_position - event.position).abs();
		$Collision.shape.size = size;
		if event.position.x <= init_position.x && event.position.y >= init_position.y:
			position.x = event.position.x;
		elif event.position.x >= init_position.x && event.position.y <= init_position.y:
			position.y = event.position.y;
		elif event.position.x < init_position.x && event.position.y < init_position.y:
			position = event.position;
		$Collision.position = size/2;
		queue_redraw();

func _on_area_exited(area):
	if selecting && area is Draggable:
		area.set_state("area_highlighted", false);
