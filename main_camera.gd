extends Camera2D


@export var follow_me: Node2D
@export var zoom_speed: float = 1
@export var min_zoom: float = 16
@export var max_zoom: float = 64


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if follow_me != null:
		position = follow_me.position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom *= (1 + zoom_speed / zoom.x)
	if event.is_action_pressed("zoom_out"):
		zoom /= (1 + zoom_speed / zoom.x)
	zoom = clamp(zoom, Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
