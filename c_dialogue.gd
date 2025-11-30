class_name AreaDialogue extends Area2D 
@export var player : Player
@export var dialogue : String
@export var dialogueRes : Resource

func _ready() -> void:
	var manager = get_node("/root/DialogueManager")
	manager.connect("dialogue_ended",_dialogue_end)
	DialogueManager.dialogue_ended
	#connect("shit",DialogueManager.dialogue_ended,0)
	


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.inDialogue == false:
		player = body
		#var image_texture = load("res://dialogue/Test.dialogue")
		#DialogueManager.show_dialogue_balloon(image_texture)
		player.inDialogue = true
		var image_texture = load("res://dialogue/"+dialogue+".dialogue")
		DialogueManager.show_dialogue_balloon(image_texture)

func _dialogue_end():
	print("dqwijiqwjiqdw")
	player.inDialogue = false

func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
