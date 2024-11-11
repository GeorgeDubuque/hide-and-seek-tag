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
	disableKey()
	interactionArea.interact = Callable(self, "interact")
	pass
	# disableKey()

func interact(interactorPlayerId: int):
	GameManager.collect_key()
	call_deferred("queue_free")

@rpc("call_local", "authority", "reliable")
func enableKey():
	interactionArea.enable()
	mesh.transparency = 0.0

func disableKey():
	interactionArea.disable()
	mesh.transparency = 0.8
