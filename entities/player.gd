extends CharacterBody2D


const USE_ANGLE = 30 * PI / 180

#var velocity = Vector2.ZERO
var tiles_per_move = 1
var animation_speed = 3

var use_animation_speed: float:
	get:
		return 0.5 / self.animation_speed

var acceleration = 1

var movement_tween: Tween = null
var direction: Vector2 = Vector2.ZERO

var is_moving: bool:
	get:
		return (movement_tween != null) and movement_tween.is_running()

var base_light_scale = 0.02


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.dir


# Linearly interpolate between two RGB colors based on t (0 to 1).
func interpolate_color(start_color: Color, end_color: Color, t: float):
	return start_color.lerp(end_color, t)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$LightArea.texture_scale = base_light_scale + Globals.daylight_brightness()
	$LightArea.color = Globals.ambient_light_color()
	
	if can_move(direction):
		move(direction)


# Pull the friction data from the current tile in the "World" node in the parent.
func get_friction() -> float:
	var world: TileMapLayer = get_parent().get_node("World")
	var world_local = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(world_local)
	var tile_data: TileData = world.get_cell_tile_data(tile_pos)
	return tile_data.get_custom_data("friction")


# Get the angle from this entity to the mouse.
# Convert that angle to a direction: -X/+X/-Y/+Y.
func get_mouse_facing() -> float:
	var angle = int(rad_to_deg(get_angle_to(get_global_mouse_position())) + 360) % 360
	if angle >= 325 or angle < 45:
		angle = 0
	elif 45 <= angle and angle < 135:
		angle = 90
	elif 135 <= angle and angle < 225:
		angle = 180
	else:
		angle = 270
	return angle * PI / 180

func _input(event: InputEvent) -> void:
	self.direction = Vector2.ZERO
	if event.is_action_pressed("move_north", true):
		self.direction.y -= self.tiles_per_move
	if event.is_action_pressed("move_south", true):
		self.direction.y += self.tiles_per_move
	if event.is_action_pressed("move_west", true):
		self.direction.x -= self.tiles_per_move
	if event.is_action_pressed("move_east", true):
		self.direction.x += self.tiles_per_move
	if event.is_action_pressed("use", true):
		var origin_angle = get_mouse_facing()
		var use_tween = create_tween()
		$HeldItem.rotation = origin_angle
		$HeldItem.visible = true
		use_tween.tween_property($HeldItem, "rotation", origin_angle - USE_ANGLE, use_animation_speed).set_trans(Tween.TransitionType.TRANS_SINE)
		use_tween.play()
		await use_tween.finished
		use_tween = create_tween()
		use_tween.tween_property($HeldItem, "rotation", origin_angle + USE_ANGLE, use_animation_speed).set_trans(Tween.TransitionType.TRANS_SINE)
		use_tween.play()
		await use_tween.finished
		use_tween = create_tween()
		use_tween.tween_property($HeldItem, "rotation", origin_angle + 0, use_animation_speed).set_trans(Tween.TransitionType.TRANS_SINE)
		use_tween.play()
		await use_tween.finished
		$HeldItem.visible = false


func can_move(direction) -> bool:
	if self.is_moving:
		# We're already moving!
		return false
	if direction == Vector2.ZERO:
		# We're not trying to go anywhere.
		return false
	$MovementRay.target_position = direction
	$MovementRay.force_raycast_update()
	return not $MovementRay.is_colliding()


func move(direction):
	movement_tween = create_tween()
	var target_position = position + direction
	var friction = get_friction()
	movement_tween.tween_property(self, "position", target_position, friction / animation_speed).set_trans(Tween.TransitionType.TRANS_LINEAR)
	movement_tween.play()
