class_name Flashlight
extends Node3D


@onready var item: Item = $Item
@export var light: SpotLight3D

@export var on: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item.use_item = Callable(self, "turn_on_off")
	print(get_multiplayer_authority())

func turn_on_off():
	toggle()
	if (!multiplayer.is_server()):
		server_toggle.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func server_toggle():
	toggle()

@rpc("authority", "call_remote", "reliable")
func multicast_toggle():
	toggle()

func toggle():
	on = !on
	light.visible = on
