extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.world_time = Globals.WorldTime.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Globals.world_time.update(delta)
