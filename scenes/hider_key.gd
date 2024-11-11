class_name HiderKey extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var hiderColor: globals.HiderColor:
	set(value):
		hiderColor = value
		print("setting key color to: ", hiderColor)
		hiderKeyRes = GameManager.hiderKeys.filter(func(key): return key.hiderColor == value)[0]

var hiderKeyRes: HiderKeyRes:
	set(value):
		hiderKeyRes = value
		mesh = $MeshInstance3D
		mesh.material_override = hiderKeyRes.material


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# disableKey()

@rpc("call_local", "any_peer", "reliable")
func enableKey(player_id):
	if (multiplayer.get_unique_id() == player_id):
		print("ENABLING key on ", multiplayer.get_unique_id())
		print("enabling key collider with path ", $InteractionArea/CollisionShape3D.get_path())
		$InteractionArea/CollisionShape3D.disabled = false
		mesh.transparency = 0.0
	else:
		print("DISABLING key on ", multiplayer.get_unique_id())
		print("disabling key collider with path ", $InteractionArea/CollisionShape3D.get_path())
		$InteractionArea/CollisionShape3D.disabled = true
		mesh.transparency = 0.8
	# var material: Material = hiderKeyRes.material.duplicate()
	# var meshColor: Color = material.albedo_color
	# meshColor.a = 1.0
	# material.albedo_color = meshColor
	# mesh.set_surface_override_material(0, material)

# func disableKey():
	# print("disabling key on ", multiplayer.get_unique_id())
	# $InteractionArea/CollisionShape3D.disabled = true
	# mesh.transparency = 0.8
	# var material: Material = hiderKeyRes.material.duplicate()
	# var meshColor: Color = material.albedo_color
	# meshColor.a = 0.5
	# material.albedo_color = meshColor
	# mesh.set_surface_override_material(0, material)
