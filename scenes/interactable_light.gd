extends Node3D


@onready var interactionArea: InteractionArea = $WallLamp/InteractionArea

@export var light: OmniLight3D
@export var lightMesh: MeshInstance3D
var on: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.interact = Callable(self, "turn_on_off")


func turn_on_off(playerInteractor: PlayerInteractor):
	on = !on
	light.visible = on
	lightMesh.get_surface_override_material(0).emission_enabled = on
