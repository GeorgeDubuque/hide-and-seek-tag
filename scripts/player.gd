# COPYRIGHT Colormatic Studios
# MIT licence
# Quality Godot First Person Controller v2
class_name Player


extends CharacterBody3D


## The settings for the character's movement and feel.
@export_category("Player")
## The speed that the character moves at without crouching or sprinting.
@export var base_speed: float = 3.0
## The speed that the character moves at when sprinting.
@export var sprint_speed: float = 6.0
## The speed that the character moves at when crouching.
@export var crouch_speed: float = 1.0

## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var acceleration: float = 10.0
## How high the player_id jumps.
@export var jump_velocity: float = 4.5
## How far the player_id turns when the mouse is moved.
@export var mouse_sensitivity: float = 0.1
## Invert the Y input for mouse and joystick
@export var invert_mouse_y: bool = false # Possibly add an invert mouse X in the future
## Wether the player_id can use movement inputs. Does not stop outside forces or jumping. See Jumping Enabled.
@export var canMove: bool = true

# Whether the player_id is tagger or taggee
@export var playerType: globals.PlayerType

# only applicable to hiders (which key they are looking for)
@export var hiderColor: globals.HiderColor
@export var hiderKeyRes: HiderKeyRes


# Whether the player_id is tagger or taggee
var isHider: bool:
	get:
		return playerType == globals.PlayerType.HIDER
# Whether the player_id is tagger or taggee
var isTagger: bool:
	get:
		return playerType == globals.PlayerType.TAGGER

var isFrozen: bool:
	get:
		return playerStatus == globals.PlayerStatus.FROZEN

var username: String

## The reticle file to import at runtime. By default are in res://addons/fpc/reticles/. Set to an empty string to remove.
@export_file var default_reticle

@export_group("Nodes")
## The node that holds the camera. This is rotated instead of the camera for mouse input.
@export var HEAD: Node3D
@export var GRAPHICS: Node3D
@export var CAMERA: Camera3D
@export var HEADBOB_ANIMATION: AnimationPlayer
@export var ANIMATION_TREE: AnimationTree
# @export var JUMP_ANIMATION: AnimationPlayer
# @export var CROUCH_ANIMATION: AnimationPlayer
@export var COLLISION_MESH: CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP: String = "jump"
@export var LEFT: String = "ui_left"
@export var RIGHT: String = "ui_right"
@export var FORWARD: String = "ui_up"
@export var BACKWARD: String = "ui_down"
## By default this does not pause the game, but that can be changed in _process.
@export var PAUSE: String = "ui_cancel"
@export var CROUCH: String = "crouch"
@export var SPRINT: String = "sprint"

# Uncomment if you want controller support
#@export var controller_sensitivity : float = 0.035
#@export var LOOK_LEFT : String = "look_left"
#@export var LOOK_RIGHT : String = "look_right"
#@export var LOOK_UP : String = "look_up"
#@export var LOOK_DOWN : String = "look_down"

@export_group("Feature Settings")
## Enable or disable jumping. Useful for restrictive storytelling environments.
@export var jumping_enabled: bool = true
## Wether the player_id can move in the air or not.
@export var in_air_momentum: bool = true
## Smooths the feel of walking.
@export var motion_smoothing: bool = true
@export var sprint_enabled: bool = true
@export var crouch_enabled: bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode: int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode: int = 0
## Wether sprinting should effect FOV.
@export var dynamic_fov: bool = true
## If the player_id holds down the jump button, should the player_id keep hopping.
@export var continuous_jumping: bool = true
## This determines wether the player_id can use the pause button, not wether the game will actually pause.
@export var pausing_enabled: bool = true
## Use with caution.
@export var gravity_enabled: bool = true

@export_group("References")
@onready var playerBodyMesh: MeshInstance3D = $Graphics/Mesh
@export var noneMaterial: StandardMaterial3D
@export var taggerMaterial: StandardMaterial3D
@export var hiderMaterial: StandardMaterial3D

@onready var playerInteractor: PlayerInteractor = $Head/PlayerInteractor


@export_group("Animation State")
@export var input_dir: Vector2
@export var on_floor: bool
@export var low_ceiling: bool = false # This is for when the cieling is too low and the player_id needs to crouch.
@export var was_on_floor: bool = true # Was the player_id on the floor last frame (for landing animation)
## Enables the view bobbing animation.
@export var view_bobbing: bool = true
## Enables an immersive animation when the player_id jumps and hits the ground.
@export var jump_animation: bool = true
@export var play_jump_anim: bool = false
@export var state: String = "normal"
@export var current_speed: float = 0.0
@export var current_animation: String
@export var speed: float = base_speed

# Member variables
# States: normal, crouching, sprinting
@export var playerStatus: globals.PlayerStatus = globals.PlayerStatus.NONE

# The reticle should always have a Control node as the root
var RETICLE: Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


# Set by the authority, synchronized on spawn.
@export var player_id := 1:
	set(id):
		player_id = id
		# Give authority over the player_id input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
		$Head/PlayerInteractor.set_multiplayer_authority(id)

@onready var frozenIndicator = $FrozenIndicator
@onready var interactorRayCast = $Head/PlayerInteractor
@onready var graphics = $Graphics
@onready var input = $PlayerInput

@export var tagInteractionArea: InteractionArea
@export var unfreezeInteractionArea: InteractionArea
var activeInteractable: InteractionArea

func _ready():
	if player_id == multiplayer.get_unique_id():
		CAMERA.current = true
		$Graphics.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$UserInterface.show()
	else:
		$UserInterface.hide()

	#It is safe to comment this line if your game doesn't start with the mouse captured

	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	if is_multiplayer_authority():
		if default_reticle:
			change_reticle(default_reticle)
	
	# Reset the camera position
	# If you want to change the default head height, change these animations.
	# HEADBOB_ANIMATION.play("RESET")
	# JUMP_ANIMATION.play("RESET")
	# CROUCH_ANIMATION.play("RESET")
	
	check_controls()

	# Bind callables for interactables on player
	tagInteractionArea.interact = Callable(self, "freeze_player")
	unfreezeInteractionArea.interact = Callable(self, "unfreeze_player")

func set_username(new_username: String):
	username = new_username
	$Label_Username.text = new_username
	

func check_controls(): # If you add a control, you might want to add a check for it here.
	# The actions are being disabled so the engine doesn't halt the entire project in debug mode
	if !InputMap.has_action(JUMP):
		push_error("No control mapped for jumping. Please add an input map control. Disabling jump.")
		jumping_enabled = false
	if !InputMap.has_action(LEFT):
		push_error("No control mapped for move left. Please add an input map control. Disabling movement.")
		canMove = false
	if !InputMap.has_action(RIGHT):
		push_error("No control mapped for move right. Please add an input map control. Disabling movement.")
		canMove = false
	if !InputMap.has_action(FORWARD):
		push_error("No control mapped for move forward. Please add an input map control. Disabling movement.")
		canMove = false
	if !InputMap.has_action(BACKWARD):
		push_error("No control mapped for move backward. Please add an input map control. Disabling movement.")
		canMove = false
	if !InputMap.has_action(PAUSE):
		push_error("No control mapped for pause. Please add an input map control. Disabling pausing.")
		pausing_enabled = false
	if !InputMap.has_action(CROUCH):
		push_error("No control mapped for crouch. Please add an input map control. Disabling crouching.")
		crouch_enabled = false
	if !InputMap.has_action(SPRINT):
		push_error("No control mapped for sprint. Please add an input map control. Disabling sprinting.")
		sprint_enabled = false

@rpc("any_peer", "call_local", "reliable")
func set_player_status(newStatus: globals.PlayerStatus):
	# playerStatus = newStatus
	print("client ", multiplayer.get_unique_id(), " recieved set_player_status to ", newStatus, " on ", get_path())
	match newStatus:
		globals.PlayerStatus.NONE:
			playerStatus = globals.PlayerStatus.NONE
			tagInteractionArea.collider.disabled = true # enable freezing
			unfreezeInteractionArea.collider.disabled = true # disable unfreezing
			frozenIndicator.hide()

		globals.PlayerStatus.UNFROZEN:
			playerStatus = globals.PlayerStatus.UNFROZEN
			tagInteractionArea.collider.disabled = false # enable freezing
			unfreezeInteractionArea.collider.disabled = true # disable unfreezing
			frozenIndicator.hide()
		
		globals.PlayerStatus.FROZEN:
			playerStatus = globals.PlayerStatus.FROZEN
			tagInteractionArea.collider.disabled = true # disable tagging
			unfreezeInteractionArea.collider.disabled = false # enable unfreezing
			frozenIndicator.show()
	
	GameManager.update_player_status(player_id, newStatus)

@rpc("any_peer", "call_local", "reliable")
func set_player_position(newPos: Vector3):
	position = newPos

func unfreeze_player(interactorPlayerId: int):
	var interactingPlayer = GameManager.id_to_players[interactorPlayerId]
	if isFrozen && interactingPlayer.isHider:
		# GameManager.setPlayerStatus.rpc_id(1, globals.PlayerStatus.UNFROZEN, multiplayer.get_unique_id())
		set_player_status.rpc(globals.PlayerStatus.UNFROZEN)

func freeze_player(interactorPlayerId: int):
	var interactingPlayer = GameManager.id_to_players[interactorPlayerId]
	if !isFrozen && interactingPlayer.isTagger:
		print("freeze player_id being called on ", GameManager.id_to_players[multiplayer.get_unique_id()])
		# print(GameManager.id_to_players[multiplayer.get_unique_id()], " calling setPlayerStatus on server with status FROZEN")
		# GameManager.setPlayerStatus.rpc_id(1, globals.PlayerStatus.FROZEN, multiplayer.get_unique_id())
		set_player_status.rpc(globals.PlayerStatus.FROZEN)

@rpc("call_local")
func set_hider_color(newHiderColor: globals.HiderColor):
	if newHiderColor == null:
		return
	hiderColor = newHiderColor
	var matchingHiderKeyRes = GameManager.hiderKeys.filter(func(key): return key.hiderColor == newHiderColor)
	if matchingHiderKeyRes.size() > 0:
		hiderKeyRes = matchingHiderKeyRes[0]
		playerBodyMesh = $Graphics/Mesh
		playerBodyMesh.material_override = hiderKeyRes.material

# @rpc("any_peer", "reliable", "call_local")
func set_player_type(type: globals.PlayerType):
	playerType = type
	match type:
		globals.PlayerType.NONE:
			tagInteractionArea.collider.disabled = true
			unfreezeInteractionArea.collider.disabled = true

			print("setting none ", self, " to none material")
			playerBodyMesh = $Graphics/Mesh
			playerBodyMesh.material_override = noneMaterial
		globals.PlayerType.TAGGER:
			tagInteractionArea.collider.disabled = true
			unfreezeInteractionArea.collider.disabled = true
			playerInteractor.collision_mask = globals.LAYER_INTERACT | globals.LAYER_FREEZE

			print("setting tagger ", self, " to none material")
			playerBodyMesh = $Graphics/Mesh
			playerBodyMesh.material_override = noneMaterial
		globals.PlayerType.HIDER:
			tagInteractionArea.collider.disabled = false
			unfreezeInteractionArea.collider.disabled = true
			playerInteractor.collision_mask = globals.LAYER_INTERACT | globals.LAYER_UNFREEZE


func change_reticle(reticle): # Yup, this function is kinda strange
	if RETICLE:
		RETICLE.queue_free()
	
	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$UserInterface.add_child(RETICLE)


func handle_debug_menu():
	if input.debug_menu_button_just_pressed:
		print("pressed debug menu button")
		if $UserInterface/DebugPanel.visible:
			$UserInterface/DebugPanel.visible = false
		else:
			$UserInterface/DebugPanel.visible = true

		input.debug_menu_button_just_pressed = false

		
func handle_jumping():
	if jumping_enabled:
		# sync bool to play jump anim on client
		if play_jump_anim:
			play_jump_anim = false
		if !play_jump_anim and input.jumping:
			play_jump_anim = true

		if continuous_jumping: # Hold down the jump button
			if input.jumping and is_on_floor() and !low_ceiling:
				# if jump_animation:
				# 	JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity # Adding instead of setting so jumping on slopes works properly
				# print("is server: ", multiplayer.is_server())
		else:
			if input.jumping and is_on_floor() and !low_ceiling:
				# if jump_animation:
				# 	JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity

		input.jumping = false


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(- HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

func handle_head_rotation():
	HEAD.rotation_degrees.y -= input.mouse_input.x * mouse_sensitivity
	GRAPHICS.rotation_degrees.y -= input.mouse_input.x * mouse_sensitivity
	if invert_mouse_y:
		HEAD.rotation_degrees.x -= input.mouse_input.y * mouse_sensitivity * -1.0
	else:
		HEAD.rotation_degrees.x -= input.mouse_input.y * mouse_sensitivity
	
	# Uncomment for controller support
	#var controller_view_rotation = Input.get_vector(LOOK_DOWN, LOOK_UP, LOOK_RIGHT, LOOK_LEFT) * controller_sensitivity # These are inverted because of the nature of 3D rotation.
	#HEAD.rotation.x += controller_view_rotation.x
	#if invert_mouse_y:
		#HEAD.rotation.y += controller_view_rotation.y * -1.0
	#else:
		#HEAD.rotation.y += controller_view_rotation.y
	
	
	input.mouse_input = Vector2(0, 0)
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if input.sprinting_pressed and state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player_id is holding sprint before moving, handle that cenerio
				if input.sprinting_pressed and state == "normal":
					enter_sprint_state()
				if input.sprinting_just_pressed:
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
	
	if crouch_enabled:
		if crouch_mode == 0:
			if input.crouch_pressed and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if input.crouch_just_pressed:
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.

func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	# if prev_state == "crouching":
	# 	CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed
	# CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	# if prev_state == "crouching":
	# 	CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed

func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 100.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 90.0, 0.3)

# func headbob_animation(moving):
# 	if moving and on_floor:
# 		var use_headbob_animation: String
# 		match state:
# 			"normal", "crouching":
# 				use_headbob_animation = "walk"
# 			"sprinting":
# 				use_headbob_animation = "sprint"
# 		
# 		var was_playing: bool = false
# 		if current_animation == use_headbob_animation:
# 			was_playing = true
# 		
# 		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
# 		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
# 		if !was_playing:
# 			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
# 			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
# 			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
# 			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
# 			# This code is extremely performant but it makes no sense.
# 		
# 	else:
# 		if current_animation == "sprint" or current_animation == "walk":
# 			HEADBOB_ANIMATION.speed_scale = 1
# 			HEADBOB_ANIMATION.play("RESET", 1)

func headbob_animation(moving):
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	match (state):
		"normal", "crouching", "sprinting":
			ANIMATION_TREE.set("parameters/BT_IWR/IWR_Blend/blend_position", horizontal_velocity.length() / sprint_speed)
			ANIMATION_TREE.set("parameters/BT_IWR/IWR_TimeScale/scale", (current_speed / base_speed) * 1.75)
		_:
			ANIMATION_TREE.set("parameters/BT_IWR/IWR_Blend/blend_position", 0)
			ANIMATION_TREE.set("parameters/BT_IWR/IWR_TimeScale/scale", (current_speed / base_speed) * 1.75)


	# if moving and on_floor:
	# 	if !was_playing:
	# 		HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
	# 		# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
	# 		# The headbob animation has two starting positions. One is at 0 and the other is at 1.
	# 		# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
	# 		# This code is extremely performant but it makes no sense.
	# 	
	# else:
	# 	if current_animation == "sprint" or current_animation == "walk":
	# 		HEADBOB_ANIMATION.speed_scale = 1
	# 		HEADBOB_ANIMATION.play("RESET", 1)

func _apply_input(delta: float):
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	# current_animation = HEADBOB_ANIMATION.current_animation
	$UserInterface/DebugPanel.add_property("Username", username, 0)

	#Gravity
	if not is_on_floor() and gravity and gravity_enabled:
		velocity.y -= gravity * delta
	
	handle_jumping()
	handle_debug_menu()
	
	input_dir = Vector2.ZERO
	if canMove && !isFrozen: # Immobility works by interrupting user input, so other forces can still be applied to the player_id
		input_dir = input.input_direction

	handle_movement(delta, input_dir)

	handle_head_rotation()
	
	# The player_id is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	
	was_on_floor = is_on_floor() # This must always be at the end of physics_process
	input.mouse_input = Vector2.ZERO

func animate():
	ANIMATION_TREE.set("parameters/conditions/grounded", is_on_floor())
	ANIMATION_TREE.set("parameters/conditions/jump", input.jumping)
	if dynamic_fov: # This may be changed to an AnimationPlayer
		update_camera_fov()

	if view_bobbing:
		headbob_animation(input_dir)


		# if !was_on_floor and on_floor: # The player_id just landed
			# match randi() % 2: # TODO: Change this to detecting velocity direction
			# 	0:
			# 		JUMP_ANIMATION.play("land_left", 0.25)
			# 	1:
			# 		JUMP_ANIMATION.play("land_right", 0.25)
func _process(delta):
	if multiplayer.is_server():
		$UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
		var status: String = state
		if !on_floor:
			status += " in the air"
		$UserInterface/DebugPanel.add_property("State", status, 4)


func _physics_process(delta):
	if multiplayer.is_server():
		on_floor = is_on_floor()
		_apply_input(delta)
		animate()

	if multiplayer.get_unique_id() == player_id:
		animate()
