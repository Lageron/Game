class_name EnemyDamageOnContact extends Area2D
@onready var collision : CollisionShape2D = $CollisionShape2D
var target : BaseChar = null
var source : Node2D = null

var hitted := false
signal hit(target, damage)


@export var singleHit : bool = true
@export var get_damage: Callable = func(): return 0




@export var dodgable : bool = true
@export var parriable : bool = true
@export var friendly : bool = false

@export var size : Vector2 = Vector2.ZERO

func _ready() -> void:
	if collision is CollisionShape2D and size != Vector2.ZERO:
		collision.shape.size = size

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not friendly:
		target = body
		if singleHit == true and hitted == false:
			var dmg = get_damage.call()
			emit_signal("hit", body, dmg)
			target._damage(dmg,self,dodgable,parriable)
			hitted = true
	if body is EnemyChar and friendly:
		target = body
		if singleHit == true and hitted == false:
			var dmg = get_damage.call()
			emit_signal("hit", body, dmg)
			target._damage(dmg)
			hitted = true
		
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		hitted = false
	
