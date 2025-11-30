extends Sprite2D

func _input(event):
	if event.is_action_pressed("interact"):
		var image_texture = load("res://dialogue/Test.dialogue")
		DialogueManager.show_dialogue_balloon(image_texture)
