extends Node2D


@onready var select_area = $SelectArea;

# Called when the node enters the scene tree for the first time.
func _ready():
	$TerrainUpload.current_dir = "/";
	$TerrainUpload.set_filters(["*.png"]);
	$TerrainExport.current_dir = "/";
	$TerrainExport.current_file = "untitled" + $TerrainMap.file_ext;
	$TerrainExport.set_filters(["*" + $TerrainMap.file_ext]);
	$TerrainImport.current_dir = "/";
	$TerrainImport.set_filters(["*" + $TerrainMap.file_ext]);

func _on_terrain_upload_files_selected(paths):
	for path in paths:
		$TerrainMap.add_terrain(path);
		
func _on_back_button_pressed():
	SceneSwitcher.goto_scene("res://scenes/MainMenu/MainMenu.tscn");

func _on_upload_button_pressed():
	$TerrainUpload.visible = true;
	
func _on_terrain_export_button_pressed():
	$TerrainExport.visible = true;

func _on_terrain_import_button_pressed():
	$TerrainImport.visible = true;

func _on_terrain_save_dir_selected(dir):
	var current_file = $TerrainExport.current_file;
	if current_file.length() <= 0:
		current_file = "untitled" + $TerrainMap.file_ext;
	if dir.length() > 0:
		current_file = "/" + current_file;
	var file_path = dir + current_file;
	if !file_path.ends_with($TerrainMap.file_ext):
		file_path += $TerrainMap.file_ext;
	var file = FileAccess.open(file_path, FileAccess.WRITE);
	file.store_var($TerrainMap.get_terrain_map());


func _on_terrain_import_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ);
	$TerrainMap.load_terrain_map(file.get_var());
