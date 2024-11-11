class_name HiderKey extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var hiderColor: globals.HiderColor:
	set(value):
		hiderColor = value
		print(hiderColor)
		hiderKeyRes = GameManager.hiderKeys.filter(func(key): return key.hiderColor == value)[0]

var hiderKeyRes: HiderKeyRes:
	set(value):
		hiderKeyRes = value
		print("setting hiderkeyres: ", hiderKeyRes.material, " on mesh: ", mesh)
		mesh.material_override = hiderKeyRes.material


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.disable()
	mesh = $MeshInstance3D

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
