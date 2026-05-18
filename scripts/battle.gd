extends CanvasLayer

signal battle_finished

# State Machine
enum State { INIT, PLAYER_TURN, ENEMY_TURN, WIN, LOSE, END }
var current_state = State.INIT

# Simple Stats
var player_max_hp
var player_hp
var enemy_max_hp = 15
var enemy_hp = 15

# Node References
@onready var dialogue_label = $DialogueLabel
@onready var action_buttons = $ActionButtons
@onready var player_hp_label = $PlayerHP
@onready var enemy_hp_label = $EnemyHP
@onready var scene_manager = get_node("/root/SceneManager")
@onready var player_hp_bar = $PlayerHPBar
@onready var enemy_hp_bar = $EnemyHPBar

func _ready():
	# Get HP values from scene manager
	player_max_hp = scene_manager.player_max_hp
	player_hp = scene_manager.player_current_hp
	# Set up the maximum values for the HP bars
	player_hp_bar.max_value = player_max_hp
	enemy_hp_bar.max_value = enemy_max_hp
	# Start the battle as soon as the scene loads
	start_battle()

func start_battle():
	current_state = State.INIT
	update_ui()
	action_buttons.hide() # Hide buttons until it's our turn
	
	display_text("A wild monster appeared!")
	# Wait 1.5 seconds so the player can read the text
	await get_tree().create_timer(1.5).timeout 
	
	player_turn()

func player_turn():
	current_state = State.PLAYER_TURN
	display_text("What will you do?")
	action_buttons.show() # Show Attack/Run buttons

func _on_attack_button_pressed():
	if current_state != State.PLAYER_TURN: 
		return # Prevent clicking if it's not our turn
		
	action_buttons.hide()
	display_text("You attacked!")
	await get_tree().create_timer(1.0).timeout
	
	# Deal damage
	enemy_hp -= 5
	enemy_hp = max(0, enemy_hp) # Prevents HP from going into negatives
	update_ui()
	
	# Check for win condition
	if enemy_hp == 0:
		win()
	else:
		enemy_turn()

func _on_run_button_pressed():
	if current_state != State.PLAYER_TURN: 
		return
		
	action_buttons.hide()
	display_text("You tried to run away...")
	await get_tree().create_timer(1.0).timeout
	
	# 50% chance to run away successfully
	if randf() > 0.5: 
		display_text("Got away safely!")
		# saves hp
		scene_manager.player_current_hp = player_hp
		await get_tree().create_timer(1.5).timeout
		end_battle()
	else:
		display_text("Failed to escape!")
		await get_tree().create_timer(1.5).timeout
		enemy_turn()

func enemy_turn():
	current_state = State.ENEMY_TURN
	display_text("The enemy attacks!")
	await get_tree().create_timer(1.0).timeout
	
	# Enemy deals damage
	player_hp -= 4
	player_hp = max(0, player_hp)
	update_ui()
	
	# Check for lose condition
	if player_hp == 0:
		lose()
	else:
		player_turn()

func win():
	current_state = State.WIN
	# plus 1 defeated enemies
	scene_manager.player_current_hp = player_hp
	scene_manager.enemies_defeated += 1
	# Check if we beat the game
	if scene_manager.enemies_defeated >= scene_manager.enemies_to_win:
		# change this to victory/credit screen?
		display_text("You beat the game!")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		# Tell the player how many are left
		var remaining = scene_manager.enemies_to_win - scene_manager.enemies_defeated
		display_text("You won! " + str(remaining) + " remaining.")
		await get_tree().create_timer(2.0).timeout
		end_battle()

func lose():
	current_state = State.LOSE
	display_text("You blacked out!")
	await get_tree().create_timer(1.5).timeout
	# Send the player back to the main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func end_battle():
	current_state = State.END
	battle_finished.emit()

# Helper functions to keep code clean
func display_text(text: String):
	dialogue_label.text = text

func update_ui():
	player_hp_label.text = "Player HP: " + str(player_hp) + "/" + str(player_max_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp) + "/" + str(enemy_max_hp)
	player_hp_bar.value = player_hp
	enemy_hp_bar.value = enemy_hp
