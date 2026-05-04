extends CharacterBody2D

@export var walk_speed = 4.0
const TILE_SIZE = 16

# Player's position on start tile before moving to another tile
var initial_position = Vector2(0,0)

# Stores which direction the player's moving
var input_direction = Vector2(0,0)

# Flag if the player is moving
var is_moving = false

# Ranging from 0.0 to 1.0, helps interpolate between tiles, so we know what position we should set the player to be
var percent_moved_to_next_tile = 0.0

# Function runs automatically when game starts
func _ready():
	initial_position = position # Gets the position of the player

# Runs every frame and handles the overall movement, e.g. checks if we're moving or not, gets input if we're stationary, and updates position if we're moving
# Delta is the time passed since the last frame (like 0.016 seconds if running at 60fps). we use it so movement speed stays the same no matter the framerate
func _physics_process(delta):
	# For every frame, if is_moving == false, we check if we have an input direction
	if is_moving == false:
		process_player_input()
	# Move if we have an input direction
	elif input_direction != Vector2.ZERO:
		move(delta)
	# If we don't have an input direction, set to is_moving = false again
	else:
		is_moving = false

# Checks which arrow keys were pressed and sets the movement direction (up/down/left/right)
# Also prevents diagonal movement by only allowing horizontal OR vertical input at a time
func process_player_input():
	# If we're not moving vertically, THEN check for horizontal key presses/input
	# Int(true) becomes 1, int(false) becomes 0, so that's how we get -1, 0, or 1
	if input_direction.y == 0: 
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	# If we're not moving horizontally, THEN check for vertical key presses/input
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	# If we pressed any direction (not zero), save where we started and start moving
	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true

# Handles how we actually move between tiles e.g. adds progress each frame, snaps to destination when done, or smoothly moves to "in-between" position
func move(delta):
	percent_moved_to_next_tile += walk_speed * delta # Delta is the amount of time passed since the last frame
	# If we've reached or passed 100% progress (1.0), snap directly to the target tile
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	# Else we're still on the way to the next tile, so interpolate (smoothly move) between start and end position
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	
