extends Node3D


@onready var item: Item = $Item
@export var light: SpotLight3D

@export var on: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item.use_item = Callable(self, "turn_on_off")

func turn_on_off():
	on = !on
	light.visible = on
