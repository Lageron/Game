extends EnemyChar

var player : Player
var vecToPlayer : Vector2
var disToPlayer : float
@export var attack : int = 1
var my_random_number : int

@onready var Notify : EnemyPlayerNotify = $PlayerNotify
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage
@onready var timer : Timer = $Phase
@onready var anim : AnimatedSprite2D = $Sprite

@onready var Scream : AudioStreamPlayer2D = $Scream
@onready var Scream2 : AudioStreamPlayer2D = $Scream2
@onready var Scream3 : AudioStreamPlayer2D = $Scream3
@onready var Spawn : AudioStreamPlayer2D = $Spawn
@onready var Jackpot : AudioStreamPlayer2D = $Jackpot
@onready var Stheme : AudioStreamPlayer2D = $Theme
@onready var ThemeBazar : AudioStreamPlayer2D = $ThemeBazar


@export var enemyCountToSpawn : int = 1

@export var CryProjectile : PackedScene
@export var Enemy : PackedScene

var rng = RandomNumberGenerator.new()
var rng2 = RandomNumberGenerator.new()
	
func _ready() -> void:
	hp = hpMax
	anim.play("Idle")
	ThemeBazar.play()
	

func _physics_process(delta: float) -> void:
	if not ThemeBazar.playing:
		ThemeBazar.play()
	if is_instance_valid(Notify.player):
		player = Notify.player
	if player != null:
		if ThemeBazar.playing:
			ThemeBazar.stop()
		if not Stheme.playing:
			Stheme.play()
		disToPlayer = global_position.distance_to(player.global_position)
		vecToPlayer =(player.global_position-global_position).normalized()
	if disToPlayer <= 600 and my_random_number == 1:
		attack = 1
	elif my_random_number == 2:
		attack = 2
	elif my_random_number == 3:
		attack = 3
	elif my_random_number == 4:
		attack = 1
	if attack == 1: 
		phase_1(delta)
	elif  attack == 2: 
		phase_2(delta)
	elif attack == 3: 
		phase_3(delta)
	else: idle(delta)
	
	
		
func _damage(damage) -> void:
	if hp > 0:
		hp -= damage 
	else :
		_death()
		
func _death() -> void:
	queue_free()
	Stheme.stop()
	
func _updateState() -> void:
	timeToAttack = timeToAttackCur
	single_codition = false
	my_random_number = rng.randi_range(0, 4)


var cryCDMax : float = 0.1
var cryCD : float = 0
var single_codition := false

func _attacking(delta):
	timeToAttackCur -= delta
	if timeToAttack <= 0:
		_updateState()

func phase_1(delta)-> void:
	anim.play("Scream")
	if not Scream.playing and single_codition == false:
		Scream.play()
		single_codition = true
		print(single_codition)
	if cryCD < cryCDMax:
		cryCD += delta
	else :
		var cry : Projectile = CryProjectile.instantiate()
		cry.source = self
		cry.scale
		add_child(cry)  
		cryCD = 0
func _on_scream_finished() -> void:
	if attack == 1:
		_updateState()
var timeToAttack : float = 8
var timeToAttackCur : float = 0
var bitCoin : Array[EnemyChar]
var enemyRandom : int = rng2.randi_range(0, 6)

func phase_2(delta)-> void:
	
	
	enemyRandom = rng2.randi_range(0, 10)
	if enemyRandom > 5 and not Jackpot.playing:
		Jackpot.play()
	timeToAttack -= delta
	anim.play("Spawning")
	
	for i in bitCoin.size():
		bitCoin[i]  = Enemy.instantiate()
	_attacking(delta)
	
func phase_3(delta)-> void:
	_attacking(delta)
func phase_4(delta)-> void:
	_attacking(delta)
func idle(delta)-> void:
	_attacking(delta)
	anim.play("Idle")
