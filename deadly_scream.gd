extends Projectile
var existFor : float = 0
var existForMax : float = 0.3
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage

func _ready() -> void:
	damage = 4
func _physics_process(delta: float) -> void:
	existFor+= delta
	scale *= existFor+1
	modulate.a = 0.2 + abs(existForMax - existFor)
	if existFor > existForMax:
		queue_free()
	ContactDamage.get_damage = func(): return damage\
	ContactDamage.source = source
