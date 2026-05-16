extends Node2D

const GrassStepEffect = preload("res://scenes/grass_step_effect.tscn")

var player_inside: bool = false

# Get access to AnimationPlayer 
@onready var anim_player = $AnimationPlayer

# On when we enter tall grass, we play the "Stepped" tall grass animation
func _on_area_2d_body_entered(body: Node2D) -> void:
	player_inside = true
	anim_player.play("Stepped")
	player_in_grass()
	# Check if the object stepping into the grass is player
	if body.has_method("try_start_battle"):
		# Wait a tiny bit for the player to finish moving onto the tile before triggering battle
		await get_tree().create_timer(0.16).timeout
		body.try_start_battle()


func player_in_grass():
	if player_inside == true:
		var grass_step_effect = GrassStepEffect.instantiate()
		grass_step_effect.position = position
		get_tree().current_scene.add_child(grass_step_effect)
