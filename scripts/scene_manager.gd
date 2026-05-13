extends Node2D

var next_scene: String = ""

func _ready() -> void:
	var town = load("res://scenes/town.tscn").instantiate()
	$CurrentScene.add_child(town)

func _process(delta: float) -> void:
	pass

func transition_to_scene(new_scene: String):
	next_scene = new_scene
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")

func finished_fading():
	# Delete current scene 
	for child in $CurrentScene.get_children():
		child.queue_free()
	
	# Create next scene
	var new_scene_resource = load(next_scene)
	if new_scene_resource:
		var new_scene_instance = new_scene_resource.instantiate()
		$CurrentScene.add_child(new_scene_instance)
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
