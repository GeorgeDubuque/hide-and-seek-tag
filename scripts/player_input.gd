class_name PlayerInput
extends Node

@export var JUMP: String = "jump"
@export var LEFT: String = "ui_left"
@export var RIGHT: String = "ui_right"
@export var FORWARD: String = "ui_up"
@export var BACKWARD: String = "ui_down"
## By default this does not pause the game, but that can be changed in _process.
@export var PAUSE: String = "ui_cancel"
@export var CROUCH: String = "crouch"
@export var SPRINT: String = "sprint"
@export var INTERACT: String = "interact"
@export var DEBUG_MENU: String = "debug_menu"
@export var FLASHLIGHT: String = "flashlight"

var input_direction := Vector2()
var jumping: float
var sprinting_just_pressed := false
var sprinting_pressed := false
var crouch_just_pressed := false
var crouch_pressed := false
var pause_button_just_pressed := false
var interact_button_just_pressed := false
var debug_menu_button_just_pressed := false
var use_item := false
var mouse_input := Vector2()
var username: String

var last_mouse_movement: Vector2 # relative mouse movement set in unhandled input

# Called when the node enters the scene tree for the first time.
func _ready():
	# if get_multiplayer_authority() == multiplayer.get_unique_id():
	# 	username = Steam.getPersonaName()
	# 	print("setting username to: ", username)
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_unhandled_input(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	if not is_multiplayer_authority():
		return


	input_direction = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	sprinting_just_pressed = Input.is_action_just_pressed(SPRINT)
	sprinting_pressed = Input.is_action_pressed(SPRINT)
	crouch_just_pressed = Input.is_action_just_pressed(CROUCH)
	crouch_pressed = Input.is_action_pressed(CROUCH)

	mouse_input.x += last_mouse_movement.x
	mouse_input.y += last_mouse_movement.y
	last_mouse_movement = Vector2.ZERO


	if Input.is_action_just_pressed(INTERACT):
		interact_button_just_pressed = true

	if Input.is_action_just_pressed(DEBUG_MENU):
		debug_menu_button_just_pressed = true


func _process(delta: float) -> void:
	jumping = Input.get_action_strength(JUMP)
	pause_button_just_pressed = Input.is_action_just_pressed(PAUSE)

	use_item = Input.is_action_just_pressed(FLASHLIGHT)
	if pause_button_just_pressed:
		# You may want another node to handle pausing, because this player may get paused too.
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#get_tree().paused = false
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				#get_tree().paused = false


func _unhandled_input(event: InputEvent):
	mouse_input = Vector2.ZERO
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		last_mouse_movement = event.relative # passing relative mouse movement