extends Node2D

# Get access to AnimationPlayer 
@onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# On when we enter tall grass, we play the "Stepped" tall grass animation
func _on_area_2d_body_entered(body: Node2D) -> void:
	anim_player.play("Stepped")
	# Check if the object stepping into the grass is player
	if body.has_method("try_start_battle"):
		# Wait a tiny bit for the player to finish moving onto the tile before triggering battle
		await get_tree().create_timer(0.16).timeout
		body.try_start_battle()
