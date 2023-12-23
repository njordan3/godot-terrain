extends Draggable
class_name ImageTerrain


var image: Image;
var bitmap: BitMap = BitMap.new();
var polygons: Array[Polygon2D] = [];
var collision_polygons: Array[CollisionPolygon2D] = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

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
