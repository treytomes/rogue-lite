extends CharacterBody2D


#var velocity = Vector2.ZERO
var tiles_per_move = 1
var animation_speed = 3
var acceleration = 1

var movement_tween: Tween = null
var direction: Vector2 = Vector2.ZERO

var is_moving: bool:
	get:
		return (movement_tween != null) and movement_tween.is_running()

var base_light_scale = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.dir


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$LightArea.texture_scale = base_light_scale + (1 - sin(Globals.world_time.fract_day * PI))
	
	if can_move(direction):
		move(direction)


# Pull the friction data from the current tile in the "World" node in the parent.
func get_friction() -> float:
	var world: TileMapLayer = get_parent().get_node("World")
	var world_local = world.to_local(global_position)
	var tile_pos: Vector2i = world.local_to_map(world_local)
	var tile_data: TileData = world.get_cell_tile_data(tile_pos)
	return tile_data.get_custom_data("friction")
		

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
