extends EnemyChar

@onready var Notify : EnemyPlayerNotify = $PlayerNotify
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage
@onready var Sprite : Sprite2D = $Sprite2D
@onready var Cry : AudioStreamPlayer2D = $Cry
@export var CryProjectile : PackedScene

var cryCDMax : float = 0.1
var cryCD : float = 0
@export var MaxAggroTime : float = 0.25
var AggroTimer : float = MaxAggroTime
var player : Player
var vecToPlayer : Vector2

func _ready() -> void:
	damage = damageBase * damageMultiplier
	hp = hpMax
func _physics_process(delta: float) -> void:
	#Notify.collision.shape.size = Vector2(200,200)
	player = Notify.player
	if player != null:
		vecToPlayer = (player.position-global_position).normalized()
		'Sprite.look_at(player.position.normalized())'
		if AggroTimer > 0:
			_active(delta)
			AggroTimer-=delta
		elif AggroTimer <= 0:
			_attack(delta)
	else:
		_updateState()
		_passive()
	move_and_slide()
		
func _updateState()-> void:
	velocity = Vector2.ZERO
	AggroTimer = MaxAggroTime
func _passive()-> void:
	Sprite.modulate = Color.WHITE
	velocity = Vector2.ZERO
func _active(delta : float) -> void:
	Sprite.modulate = Color.YELLOW
	velocity = Vector2.ZERO
func _attack(delta : float)-> void:
	if not Cry.playing:
		Cry.play()
	if cryCD < cryCDMax:
		cryCD += delta
	else :
		var cry : Projectile = CryProjectile.instantiate()
		cry.source = self
		add_child(cry)  
		cryCD = 0
	velocity = vecToPlayer * Speed
	Sprite.modulate = Color.RED
	#print(vecToPlayer)
	
	
func _damage(damage) -> void:
	if hp > 0:
		hp -= damage 
	else :
		_death()

func _death() -> void:
	queue_free()
