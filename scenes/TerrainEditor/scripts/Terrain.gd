extends Area2D


signal on_selected(terrain);

var image: Image;
var bitmap: BitMap = BitMap.new();
var polygons: Array[Polygon2D] = [];
var collision_polygons: Array[CollisionPolygon2D] = [];
var selected: bool = false;
var selected_position: Vector2;
var highlighted: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;
	
func _process(_delta):
	if selected:
		var new_position: Vector2 = get_viewport().get_mouse_position();
		new_position -= selected_position;
		position = new_position;

func init(init_image: Image):
	image = init_image;
	var texture: ImageTexture = ImageTexture.create_from_image(image);
	var window: Vector2 = DisplayServer.window_get_size(0);
	position = Vector2(window.x/2, window.y/2);
	bitmap.create_from_image_alpha(image);
	$Sprite.texture = texture;
	$Sprite.centered = false;
	$Sprite.visible = false;
	add_to_group("terrain");
	set_up_collision();

func set_up_collision():
	var bitmap_polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, $Sprite.texture.get_size()));
	for i in polygons:
		i.queue_free();
	
	for i in collision_polygons:
		i.queue_free();
	
	for i in bitmap_polygons.size():
		polygons.append(Polygon2D.new());
		polygons[i].polygon = bitmap_polygons[i];
		polygons[i].texture = $Sprite.texture;
		add_child(polygons[i]);
		
		collision_polygons.append(CollisionPolygon2D.new());
		collision_polygons[i].polygon = bitmap_polygons[i];
		add_child(collision_polygons[i]);
	
	return bitmap_polygons

func toggle_highlight():
	highlighted = !highlighted;
	queue_redraw();

func _on_mouse_entered():
	toggle_highlight();

func _on_mouse_exited():
	toggle_highlight();

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# If overlapping other highlighted terrain, move only the top terrain
			var areas = get_overlapping_areas();
			var is_on_top = true;
			for area in areas:
				if area.highlighted && !is_greater_than(area):
					is_on_top = false;
			if is_on_top:
				selected = true;
				selected_position = to_local(event.position);
				on_selected.emit(self);
				event.canceled = true;

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected:
			selected = false;

func _on_draw():
	if (highlighted):
		draw_rect(Rect2(Vector2.ZERO, $Sprite.texture.get_size()), Color.WHITE, false);
