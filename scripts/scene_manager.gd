extends Node2D
var next_scene: String = ""
var player_location = Vector2(0,0)
var player_direction = Vector2(0,0)
var player_max_hp: int = 50
var player_current_hp: int = 50
var enemies_defeated: int = 0
var enemies_to_win: int = 3 # enemy count

func _ready() -> void:
	var house_floor = load("res://scenes/house_floor.tscn").instantiate()
	$CurrentScene.add_child(house_floor)

func _process(_delta: float) -> void:
	pass

func transition_to_scene(new_scene: String, spawn_location = Vector2(0,0), spawn_direction = Vector2(0,0)):
	next_scene = new_scene
	player_location = spawn_location
	player_direction = spawn_direction
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	# Wait for the visual fade to finish, then swap the scenes
	await $ScreenTransition/AnimationPlayer.animation_finished
	finished_fading()

func finished_fading():
	# Delete current scene 
	for child in $CurrentScene.get_children():
		child.queue_free()
	
	# Create next scene
	var new_scene_resource = load(next_scene)
	if new_scene_resource:
		var new_scene_instance = new_scene_resource.instantiate()
		$CurrentScene.add_child(new_scene_instance)
	
	# Set spawn location and direction before fading back in
	if player_location != Vector2(0,0):
		var player = $CurrentScene.get_children().back().find_child("Player")
		if player:
			player.set_spawn(player_location, player_direction)
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
