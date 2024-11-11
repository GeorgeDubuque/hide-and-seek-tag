extends Node3D


@onready var interactionArea: InteractionArea = $WallLamp/InteractionArea

@export var light: OmniLight3D
@export var lightMesh: MeshInstance3D
@export var on: bool = false

var wasOn: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.interact = Callable(self, "turn_on_off")


func turn_on_off(interactorPlayerId: int):
	on = !on
	light.visible = on

func _process(delta):
	var newMaterial = lightMesh.get_surface_override_material(0).duplicate()
	if wasOn && !on:
		newMaterial.emission_enabled = on
		lightMesh.set_surface_override_material(0, newMaterial)

	if !wasOn && on:
		newMaterial.emission_enabled = on
		lightMesh.set_surface_override_material(0, newMaterial)
	wasOn = on
