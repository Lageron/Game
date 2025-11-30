extends Node

# Загружает сцену, удаляя предыдущую полностью
# zone_pos — позиция, где игрок должен появиться
func load_scene(scene_to_load: PackedScene, player: Node2D, zone_pos: Vector2) -> void:
	if not scene_to_load or not player:
		return

	# Удаляем текущую сцену полностью
	var old_scene = get_tree().current_scene
	if old_scene:
		old_scene.queue_free()

	# Создаём новый инстанс сцены
	var new_scene = scene_to_load.instantiate()
	get_tree().current_scene = new_scene
	get_tree().root.add_child(new_scene)

	# Перемещаем игрока на позицию зоны-переходника
	player.global_position = zone_pos
