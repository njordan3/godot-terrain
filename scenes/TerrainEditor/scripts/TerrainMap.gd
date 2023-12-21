extends Node2D


var terrainScene = preload("res://scenes/TerrainEditor/Terrain.tscn");
var explosionScene = preload("res://scenes/TerrainEditor/Explosion.tscn");
var file_ext = ".terrain";

func _ready():
	pass;

func do_explode(pos: Vector2, radius: int):
	var explosion = explosionScene.instantiate();
	var collision = explosion.get_node("Collision");
	collision.shape.radius = radius;
	explosion.position = pos;
#	explosion.exploded.connect(_on_exploded);
	call_deferred("add_child", explosion);

func add_terrain(path: String):
	var image: Image = Image.load_from_file(path);
	var terrain = terrainScene.instantiate();
	terrain.init(image);
	terrain.on_selected.connect(_on_terrain_selected);
	call_deferred("add_child", terrain);

func _on_terrain_selected(terrain):
	# Set selected terrain to be the last child and therefore rendered on top
	move_child(terrain, get_children().size()-1);

func get_terrain_map():
	var terrain_map = [];
	var terrain_pieces = get_children();
	for terrain in terrain_pieces:
		terrain_map.append({
			"pos": terrain.position,
			"img": terrain.image.save_png_to_buffer(),
		});
	return terrain_map;

func load_terrain_map(terrain_pieces):
	for terrain_piece in terrain_pieces:
		var image = Image.new();
		image.load_png_from_buffer(terrain_piece["img"]);
		var terrain = terrainScene.instantiate();
		terrain.init(image);
		terrain.position = terrain_piece["pos"];
		terrain.on_selected.connect(_on_terrain_selected);
		call_deferred("add_child", terrain);
