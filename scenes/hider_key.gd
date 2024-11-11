class_name HiderKey extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var hiderColor: globals.HiderColor:
	set(value):
		hiderColor = value
		hiderKeyRes = GameManager.hiderKeys.filter(func(key): return key.hiderColor == value)[0]
		mesh.material_override = hiderKeyRes.material

var hiderKeyRes: HiderKeyRes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.disable()

func enableKey():
	interactionArea.enable()
	var meshColor: Color = mesh.material_override.color
	meshColor.a = 1.0
	mesh.material_override.color = meshColor

func disableKey():
	interactionArea.disable()
	var meshColor: Color = mesh.material_override.color
	meshColor.a = 0.5
	mesh.material_override.color = meshColor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(hiderColor)
