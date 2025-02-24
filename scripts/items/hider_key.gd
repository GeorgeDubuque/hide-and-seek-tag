class_name HiderKey extends Node3D

@onready var interactionArea: InteractionArea = $InteractionArea
@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var hiderColor: globals.HiderColor:
	set(value):
		hiderColor = value
		hiderKeyRes = GameManager.hiderKeys.filter(func(key): return key.hiderColor == value)[0]
		print("setting ", self, " color to: ", hiderKeyRes.resource_path)

var hiderKeyRes: HiderKeyRes:
	set(value):
		hiderKeyRes = value
		mesh = $MeshInstance3D
		mesh.material_override = hiderKeyRes.material.duplicate()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disableKey()
	interactionArea.interact = Callable(self, "interact")
	pass
	# disableKey()
#comment
func interact(interactorPlayerId: int):
	GameManager.collect_key()
	call_deferred("queue_free")

@rpc("call_local", "authority", "reliable")
func enableKey():
	print("Enabling %s key." % hiderColor)
	interactionArea.enable()
	mesh.transparency = 0.0

func disableKey():
	interactionArea.disable()
	mesh.transparency = 0.8
