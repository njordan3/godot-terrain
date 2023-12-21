extends Area2D


signal exploded;


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame; # needs to wait for overlapping bodies to be ready
	await get_tree().physics_frame; # 2 physics frames seems to do the trick
	explode();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass
	
func clean_up(emit: bool):
	if emit:
		exploded.emit();
	queue_free();

# https://www.reddit.com/r/godot/comments/ehzsk1/recreated_destructible_terrain_from_worms_in/
func explode():
	var overlapping_bodies = get_overlapping_bodies();
	var no_overlaps = overlapping_bodies.size() <= 0;
	var radius = $Collision.shape.radius;
	
	if !no_overlaps:
		for i in radius:
			var t: float = i/float(radius)+1; # idk what this stuff is
			var r: Vector2 = (Vector2(t, t) * 4).round();
			for a in 36:
				var rotated_point: Vector2 = Vector2(i,0).rotated(deg_to_rad(a * 10));
				var new_overlapping_bodies = [];
				for body in overlapping_bodies:
					if body.is_in_group("terrain"):
						body.bitmap.set_bit_rect(Rect2((body.to_local(position) + rotated_point).round(), r), 0);
						if (body.bitmap.get_true_bit_count() <= 0): # despawn terrain if nothing is left
							body.queue_free();
						else:
							new_overlapping_bodies.append(body);
				overlapping_bodies = new_overlapping_bodies;
				if overlapping_bodies.size() <= 0: # no more overlapping bodies, so clean up early
					clean_up(true);
					return;
	clean_up(!no_overlaps);
