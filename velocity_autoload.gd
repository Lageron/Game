extends Node

func add_external_velocity(
	target: Node,
	dir: Vector2,
	speed: float,
	time: float = 0.2,
	acce: float = 0.0,
	dece: float = 0.0
) -> Node:
	# создаём компонент
	var vel_ext = preload("res://Components/ExternalVel.gd").new()

	vel_ext.dir = dir
	vel_ext.vel = speed
	vel_ext.time = time
	vel_ext.acce = acce
	vel_ext.dece = dece

	target.add_child(vel_ext)

	return vel_ext
