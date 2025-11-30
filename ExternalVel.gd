class_name component_external_vel
extends Node

@export var vel: float = 0.0
@export var dir: Vector2 = Vector2.ZERO
@export var time: float = 1.0

@export_range(0,1) var dece: float = 0.0
@export_range(0,1) var acce: float = 0.0

var ownerChar: BaseChar
var slot_index: int = -1


func _ready() -> void:
	ownerChar = get_parent()

	if ownerChar == null:
		queue_free()
		return

	# найти свободный слот = Vector2.ZERO
	for i in ownerChar.velExtArr.size():
		if ownerChar.velExtArr[i] == Vector2.ZERO:
			slot_index = i
			break

	# если свободного нет — расширяем массив
	if slot_index == -1:
		slot_index = ownerChar.velExtArr.size()
		ownerChar.velExtArr.append(Vector2.ZERO)

	#print("start slot:", slot_index)


func _physics_process(delta: float) -> void:
	if ownerChar == null:
		queue_free()
		return

	time -= delta
	if time <= 0:
		_clear_slot()
		queue_free()
		return

	var vel_vec := _calculate_velocity(delta)
	ownerChar.velExtArr[slot_index] = vel_vec


func _calculate_velocity(delta: float) -> Vector2:
	var current_speed = vel

	if acce > 0.0:
		current_speed = lerp(0.0, vel, acce * delta * 60)

	if dece > 0.0:
		current_speed = lerp(vel, 0.0, dece * delta * 60)

	return dir.normalized() * current_speed


func _clear_slot() -> void:
	if ownerChar and slot_index >= 0 and slot_index < ownerChar.velExtArr.size():
		#print("end slot:", slot_index)
		ownerChar.velExtArr[slot_index] = Vector2.ZERO
