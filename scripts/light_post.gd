extends Node3D
@onready var interactionArea: InteractionArea = $InteractionArea
@onready var light: OmniLight3D = $OmniLight3D
var on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.interact = Callable(self, "on_interact")

func on_interact(interactorPlayerId: int):
	on = !on
	light.visible = on
