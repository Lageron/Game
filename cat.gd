extends EnemyChar

@onready var Notify : EnemyPlayerNotify = $PlayerNotify
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage
@onready var SpriteAnim : AnimatedSprite2D = $AnimatedSprite2D
@onready var Light : PointLight2D = $Light
@onready var SDash : AudioStreamPlayer2D = $SDash

@export var MaxAggroTime : float = 0.25
var AggroTimer : float = MaxAggroTime
@export var MaxAttackTime : float = 0.5
var AttackTime : float = MaxAttackTime

var triggered : bool = false


var player : Player
var vecToPlayer : Vector2

func _ready() -> void:
	damage = damageBase 
	hp = hpMax
	ContactDamage.get_damage = func(): return damage
	SpriteAnim.play("IDLE")
	
	
func _physics_process(delta: float) -> void:
	player = Notify.player
	if player != null and AggroTimer > 0:
		vecToPlayer = (player.position-global_position).normalized()
		_active(delta)
		AggroTimer-=delta
	elif player != null and AggroTimer <= 0 and AttackTime > 0:
		_attack(delta)
	else:
		_updateState()
		_passive()
	move_and_slide()
		
func _updateState() -> void:
	velocity = Vector2.ZERO
	AggroTimer = MaxAggroTime
	AttackTime = MaxAttackTime
	damageMultiplier = 0
	ContactDamage.get_damage = func(): return damageBase * damageMultiplier
func _damage(damage) -> void:
	if hp > 0:
		hp -= damage 
	else :
		_death()

func _death() -> void:
	queue_free()
func _passive() -> void:
	SpriteAnim.scale.y = 1 
	SpriteAnim.play("IDLE")
	damageMultiplier = 0
	Light.color = Color.WHITE
	velocity = Vector2.ZERO
func _transfrom(delta : float) -> void:
	SpriteAnim.play("TRANSFORM")
	SpriteAnim.scale.y = 1 + MaxAggroTime-AggroTimer
	damageMultiplier = 0
	Light.color = Color.YELLOW
	velocity = Vector2.ZERO
func _active(delta : float) -> void:
	SpriteAnim.play("IDLEAGGRESIVE")
	SpriteAnim.scale.y = 1 + MaxAggroTime-AggroTimer
	damageMultiplier = 0
	Light.color = Color.YELLOW
	velocity = Vector2.ZERO
func _following(delta : float) -> void:
	SpriteAnim.play("CAUTION")
	SpriteAnim.scale.y = 1 + MaxAggroTime-AggroTimer
	damageMultiplier = 0
	Light.color = Color.YELLOW
	velocity = Vector2.ZERO
func _attack(delta : float) -> void:
	SpriteAnim.scale.y = 1 
	SpriteAnim.play("ATTACK")
	SDash.play()
	damageMultiplier = 1
	ContactDamage.get_damage = func(): return damageBase * damageMultiplier
	AttackTime -= delta
	velocity = vecToPlayer * Speed
	Light.color = Color.RED
