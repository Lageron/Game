class_name EnemyPlayerNotify extends Area2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@export var frinedly : bool = false

var player : BaseChar
var enemyCount : int
var panicDamage : float

@export var size : Vector2 = Vector2(0,0)
 
func _physics_process(delta: float) -> void:
	if collision is CollisionShape2D and size != Vector2.ZERO:
		collision.shape.size = size
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player  and frinedly == false:
		player = body
	if body is EnemyChar and frinedly == true:
		enemyCount+=1
		panicDamage+=body.panicDamage
		


func _on_body_exited(body: Node2D) -> void:
	if body is Player and frinedly == false:
		player = null
	if body is EnemyChar and frinedly == true:
		panicDamage-=body.panicDamage
		enemyCount-=1
		
	
