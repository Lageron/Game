extends Area2D

@export var to: PackedScene  # сцена для перехода

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Передаем сцену и позицию игрока для загрузки
		SceneManager.load_scene(to, body, global_position)
