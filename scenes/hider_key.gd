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
		mesh = $MeshInstance3D
		mesh.material_override = hiderKeyRes.material


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactionArea.disable()

@rpc("call_local")
func enableKey():
	interactionArea.enable()
	var material: Material = hiderKeyRes.material.duplicate()
	var meshColor: Color = material.albedo_color
	meshColor.a = 1.0
	material.albedo_color = meshColor
	mesh.set_surface_override_material(0, material)

func disableKey():
	interactionArea.disable()
	var material: Material = hiderKeyRes.material.duplicate()
	var meshColor: Color = material.albedo_color
	meshColor.a = 0.5
	material.albedo_color = meshColor
	mesh.set_surface_override_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(hiderColor)
