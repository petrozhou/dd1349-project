extends CharacterBody2D

signal player_entering_door_signal
signal player_entered_door_signal

@export var walk_speed = 4.0
const TILE_SIZE = 16

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var ray = $BlockingRayCast
@onready var door_ray = $DoorRayCast

# Player's position on start tile before moving to another tile
var initial_position = Vector2(0,0)
# Stores which direction the player's moving
var input_direction = Vector2(0,0)
# Flag if the player is moving
var is_moving = false
# Ranging from 0.0 to 1.0, helps interpolate between tiles, so we know what position we should set the player to be
var percent_moved_to_next_tile = 0.0
# Freeze the player when entering a door (or starting a battle?)
var stop_input: bool = false

var last_direction = Vector2.DOWN

enum PlayerState {IDLE, TURNING, WALKING}
var player_state = PlayerState.IDLE

# Battle scene
const BATTLE_SCENE := preload("res://scenes/Battle.tscn")

# Called when the node enters the scene tree for the first time
func _ready():
	$Sprite2D.visible = true
	anim_tree.active = true
	initial_position = position

# For setting spawn location when walking through doors
func set_spawn(location: Vector2, direction: Vector2):
	position = location
	initial_position = location  # So first step calculates correctly
	input_direction = direction
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	stop_input = false       # Unfreeze player
	anim_tree.active = true  # Re-enable animation tree
	
# Runs every frame and handles the overall movement, e.g. checks if we're moving or not, gets input if we're stationary, and updates position if we're moving
# Delta is the time passed since the last frame (like 0.016 seconds if running at 60fps). we use it so movement speed stays the same no matter the framerate
func _physics_process(delta):
	if player_state == PlayerState.TURNING or stop_input:
		return
	# For every frame, if is_moving == false, we check if we have an input direction
	if is_moving == false:
		process_player_input()
		update_animation()
	# Move if we have an input direction
	elif input_direction != Vector2.ZERO:
		update_animation() # Here we refer to AnimationTree
		move(delta)
	# If we don't have an input direction, set to is_moving = false again
	else:
		update_animation() # Here we refer to AnimationTree
		is_moving = false

# Checks which arrow keys were pressed and sets the movement direction (up/down/left/right)
# Also prevents diagonal movement by only allowing horizontal OR vertical input at a time
func process_player_input():
	# If we're not moving vertically, THEN check for horizontal key presses/input
	# Int(true) becomes 1, int(false) becomes 0, so that's how we get -1, 0, or 1
	if input_direction.y == 0: 
		input_direction.x = int(Input.is_action_pressed("ui_right" )) - int(Input.is_action_pressed("ui_left"))
	# If we're not moving horizontally, THEN check for vertical key presses/input
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	# If we pressed any direction (not zero), save where we started and start moving
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction) # Here we refer to AnimationTree
		anim_tree.set("parameters/Walk/blend_position", input_direction) # Here we refer to AnimationTree
		initial_position = position
		is_moving = true
	else:
		update_animation()

func update_animation():
	anim_tree.set("parameters/conditions/is_moving", is_moving)
	anim_tree.set("parameters/conditions/is_idle", !is_moving)
	var blend_dir = input_direction if input_direction != Vector2.ZERO else last_direction
	anim_tree.set("parameters/Idle/blend_position", blend_dir)
	anim_tree.set("parameters/Walk/blend_position", blend_dir)
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
	
func entered_door():
	emit_signal("player_entered_door_signal")
	
# Handles how we actually move between tiles e.g. adds progress each frame, snaps to destination when done, or smoothly moves to "in-between" position
func move(delta):
	# RayCast for collision checking before applying movement logic
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2 # This gets the vector 2 of the next tile from the current
	ray.target_position = desired_step # We're changing where the ray is casting towards
	ray.force_raycast_update()
	
	# RayCast for door checking
	door_ray.target_position = desired_step
	door_ray.force_raycast_update()
	
	# First we check for door, before applying movement logic
	if door_ray.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 0.0: 
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			# Player dissapear
			$AnimationPlayer.play("Disappear")
			anim_tree.active = false
			var camera_2d = $Camera2D
			camera_2d.get_target_position() # Load new scene and clear camera from current stuff
		else: 
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	
	# Then we check for collision shapes, before applying movement logic
	elif !ray.is_colliding(): # If ray is not colliding, we can apply our normal move logic below
		percent_moved_to_next_tile += walk_speed * delta # Delta is the amount of time passed since the last frame
		
		# If we've reached or passed 100% progress (1.0), snap directly to the target tile
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false

		# Else we're still on the way to the next tile, so interpolate (smoothly move) between start and end position
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else: # If ray is colliding, we don't move
		percent_moved_to_next_tile = 0.0
		is_moving = false



# -- Battle System --
func try_start_battle():
	if randf() < 0.10:
		# Stop player movement and snap to destionation tile (so we're not stuck in between two grass tiles when exclamation mark animation plays)
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		stop_input = true
		is_moving = false
		update_animation()
		
		# Show exclamation mark above player
		var exclamation = preload("res://scenes/exclamation.tscn").instantiate()
		add_child(exclamation)
		exclamation.position = Vector2(1, -25)
		exclamation.get_node("AnimationPlayer").play("Exclamation")
		
		# Wait for exclamation animation to finish
		await exclamation.get_node("AnimationPlayer").animation_finished
		
		# Fade to black using SceneManager
		var scene_manager = get_node(NodePath("/root/SceneManager"))
		scene_manager.get_node("ScreenTransition/AnimationPlayer").play("FadeToBlack")
		await scene_manager.get_node("ScreenTransition/AnimationPlayer").animation_finished
		
		exclamation.queue_free()
		
		# Start battle
		var battle = BATTLE_SCENE.instantiate()
		get_tree().current_scene.add_child(battle)
		set_physics_process(false)
		battle.battle_finished.connect(_on_battle_finished)
		
		# Fade back to normal (now we're in battle scene)
		scene_manager.get_node("ScreenTransition/AnimationPlayer").play("FadeToNormal")


func _on_battle_finished():
	# Fade to black
	var scene_manager = get_node(NodePath("/root/SceneManager"))
	scene_manager.get_node("ScreenTransition/AnimationPlayer").play("FadeToBlack")
	await scene_manager.get_node("ScreenTransition/AnimationPlayer").animation_finished
	
	# Re-enable player
	set_physics_process(true)
	stop_input = false
	input_direction = Vector2.ZERO
	is_moving = false
	percent_moved_to_next_tile = 0.0
	
	# Fade back to overworld
	scene_manager.get_node("ScreenTransition/AnimationPlayer").play("FadeToNormal")
