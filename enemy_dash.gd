extends EnemyChar

@onready var Notify : EnemyPlayerNotify = $PlayerNotify
@onready var Line : Line2D = $CRayCast
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage
@onready var Sprite : Sprite2D = $Sprite2D
@onready var SpriteAnim : AnimatedSprite2D = $Sprite2D2
@onready var Light : PointLight2D = $Light
@onready var SDash : AudioStreamPlayer2D = $SDash

@export var MaxAggroTime : float = 0.25
var AggroTimer : float = MaxAggroTime
@export var MaxAttackTime : float = 0.5
var AttackTime : float = MaxAttackTime
var thrown := false


var player : Player
var vecToPlayer : Vector2

func _ready() -> void:
	damage = damageBase 
	hp = hpMax
	ContactDamage.get_damage = func(): return damage
	
	
func _physics_process(delta: float) -> void:
	player = Notify.player
	if not thrown:
		if player != null and AggroTimer > 0:
			vecToPlayer = (player.position-global_position).normalized()
			_active(delta)
			AggroTimer-=delta
		elif player != null and AggroTimer <= 0 and AttackTime > 0:
			_attack(delta)
		else:
			_updateState()
			_passive()
	velExternal = get_external_velocity()
	velocity = velExternal + Vel
	move_and_slide()
	
func get_external_velocity() -> Vector2:
	var sum := Vector2.ZERO
	for v in velExtArr:
		sum += v
	return sum
func _damage(damage) -> void:
	if hp > 0:
		hp -= damage 
	else :
		_death()

func _death() -> void:
	queue_free()
		
func _updateState() -> void:
	Vel = Vector2.ZERO
	AggroTimer = MaxAggroTime
	AttackTime = MaxAttackTime
	damageMultiplier = 0
	ContactDamage.get_damage = func(): return damageBase * damageMultiplier	
	
	
func _passive() -> void:
	Line.visible = false
	damageMultiplier = 0
	Light.color = Color.WHITE
	Sprite.modulate = Color.WHITE
	Vel = Vector2.ZERO
	SpriteAnim.speed_scale = 1
func _active(delta : float) -> void:
	Line.visible = true
	Line.global_rotation = vecToPlayer.angle()
	Line._updateRay()
	damageMultiplier = 0
	Light.color = Color.YELLOW
	Sprite.modulate = Color.YELLOW
	Vel = Vector2.ZERO
	SpriteAnim.speed_scale = 2
func _attack(delta : float) -> void:
	SpriteAnim.speed_scale = 5
	Line.visible = false
	SDash.play()
	damageMultiplier = 1
	ContactDamage.get_damage = func(): return damageBase * damageMultiplier
	AttackTime -= delta
	Vel = vecToPlayer * Speed
	Light.color = Color.RED
	Sprite.modulate = Color.RED
	#print(vecToPlayer)
