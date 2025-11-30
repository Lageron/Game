class_name Player extends BaseChar

@onready var cam : Camera2D = $Camera2D 
@onready var sprite : Sprite2D = $Sprite 
@onready var collision : CollisionShape2D = $CollisionShape2D 
@onready var spriteAnimate : AnimatedSprite2D = $AnimatedSprite2D 
@onready var light : PointLight2D = $Light 
@onready var panicArea : EnemyPlayerNotify = $Panic 
@onready var parrySprite : Sprite2D = $Parry

@onready var dash : AudioStreamPlayer2D = $SDash 
@onready var step : AudioStreamPlayer2D = $SWalk
@onready var swing : AudioStreamPlayer2D = $SSwing
@onready var parry : AudioStreamPlayer2D = $SParry
@onready var parry2 : AudioStreamPlayer2D = $SParry2
@onready var hurt : AudioStreamPlayer2D = $SHurt
@onready var hitWeapon1 : AudioStreamPlayer2D = $SHitShovel


@onready var barInsanity : Panel = $HP/BarI
@onready var HP : Control = $HP
@onready var Heart : AnimatedSprite2D = $HP/Heart
@onready var vienjette : TextureRect = $Vienjete
@onready var HPvienjette : TextureRect = $HPVienjette



var canMove : bool = true
var canWalk : bool = true
var canRecieveDamage  : bool = true

@export var accel : float = 5
@export var deccel : float = 5
@export var Speed : float = 750.0
@export var SpeedMultiplier = 1
var SpeedR : float = Speed 
var VelDash : Vector2 = Vector2.ZERO
var bufferedDir : Vector2 = Vector2.ZERO
var dir : Vector2 = Vector2.ZERO





@export var projectile : PackedScene
@export var particleSpark : PackedScene
@export var impact : PackedScene


func _ready() -> void:
	vienjette.visible = true
	HPvienjette.visible = true
	Heart.play()
	

var MousePos : Vector2 = Vector2.ZERO
var MousePos2 : Vector2 = Vector2.ZERO
var Mouse_motion = Vector2.ZERO

func _input(event) -> void:
	if event is InputEventMouseMotion and event.relative !=Vector2.ZERO:
		MousePos = event.relative
		Mouse_motion = event.relative
	if 	Input.is_action_just_pressed("FullScreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if _canAct():
		if Input.is_action_just_pressed("space") and DashCD <= 0:
			_dash(bufferedDir)
		if Input.is_action_pressed("Mouse1") and not is_instance_valid(attack):
			_attack()
		if Input.is_action_just_pressed("Mouse2") and parryCD <= 0:
			_parry_try()
		dir = Input.get_vector("a", "d", "w" , "s")

func _physics_process(delta: float) -> void:
	SpeedR = Speed * SpeedMultiplier
	
	dirToMouse = (get_global_mouse_position() - global_position).normalized()
	_health(delta)
	_panic(delta)
		
	
	

	if  is_instance_valid(attack):
		_attacking(delta)
		
	
	if parryCD > 0:
		parryCD -= delta
	if parryWindow > 0:
		parrySprite.visible = true
		parryWindow -= delta
		spriteAnimate.modulate = Color.RED
		parrySprite.modulate = Color.RED
	else:
		spriteAnimate.modulate = Color.WHITE
		parrySprite.visible = false
		velFromparry = 0
			
			
			
	if dir != Vector2.ZERO:
		bufferedDir = dir
	if dir and _canWalk():
		_walk(delta, dir)
	else: 
		var dec : float =  SpeedR*delta*deccel
		Vel.x = move_toward(Vel.x, Vector2.ZERO.y, dec)
		Vel.y = move_toward(Vel.y, Vector2.ZERO.x, dec)
		
	if dir and Input.is_action_pressed("space"):
		SpeedMultiplier = 1.5
		sprite.self_modulate = Color.GREEN_YELLOW
	else :
		SpeedMultiplier = 1
		sprite.self_modulate = Color.WHITE
	
	if DashCD:
		DashCD = clamp(DashCD - delta, 0 , DashCDMax)
	if DashDur > 0:
		DashDur -=delta
		sprite.scale /= 1 + DashDur
		sprite.self_modulate = Color.RED
		canRecieveDamage = false
		spriteAnimate.speed_scale = 1+DashDur*3
	elif DashDur <= 0:
		VelDash = Vector2.ZERO
		DashDur = 0
		sprite.scale.x = 0.5
		sprite.scale.y = 0.5
		sprite.self_modulate = Color.WHITE
		light.color = Color.WHITE
		canRecieveDamage = true
		spriteAnimate.speed_scale = 1
		
	#velocity = dir * Speed
	_animation(dir)
	velExternal = _get_external_velocity()
	velocity = Vel+VelDash+velExternal
	move_and_slide()	
	
func _get_external_velocity() -> Vector2:
	var sum := Vector2.ZERO
	for v in velExtArr:
		#print(v)
		sum += v
	return sum
	
var stepCD : float
func _canWalk()  -> bool:
	if DashDur > 0 or parryWindow > 0:
		#or is_instance_valid(attack)
		return false 
	else :
		true
	return true
var inDialogue : bool = false
func _canAct() -> bool:
	if inDialogue : return false
	return true
func _interruptAction() -> void:
	DashDur = 0
	parryWindow = 0
	velocity = Vector2.ZERO
func _tryToDialogue():
	if inDialogue == false:
		pass
	
	
const DIR_ANIMS_GO = ["GORIGHT", "GOFORWARD", "GOLEFT","GOBACK"]
const DIR_ANIMS_WALK = ["WALKRIGHT", "WALKFORWARD", "WALKLEFT","WALKBACK"]
const DIR_IDLE = ["IDLER", "IRDLEF", "IDLEL","IDLER"]
func _animation(dir : Vector2) -> void:
	var direction_id
	if is_instance_valid(attack):
		var angle_deg = rad_to_deg(dirToMouse.angle())                 
		angle_deg = fposmod(angle_deg + 360.0, 360.0)     
		angle_deg = fposmod(angle_deg + 45.0, 360.0)         
		direction_id = int(floor(angle_deg / 90.0))
	if parryWindow > 0:
		spriteAnimate.play("PARRY")
		
	elif dir and parryWindow <= 0:
		if is_instance_valid(attack):
			if SpeedMultiplier > 1:    
				spriteAnimate.play(DIR_ANIMS_GO[direction_id])
			else :
				spriteAnimate.play(DIR_ANIMS_WALK[direction_id])
		else :
			if SpeedMultiplier > 1:    
				if dir.y > 0: spriteAnimate.play("GOFORWARD")
				elif dir.y < 0: spriteAnimate.play("GOBACK")
				elif dir.x > 0: spriteAnimate.play("GORIGHT")
				elif dir.x < 0: spriteAnimate.play("GOLEFT")
			else :
				if dir.y > 0: spriteAnimate.play("WALKFORWARD")
				elif dir.y < 0: spriteAnimate.play("WALKBACK")
				elif dir.x > 0: spriteAnimate.play("WALKRIGHT")
				elif dir.x < 0: spriteAnimate.play("WALKLEFT")
	else :
		if is_instance_valid(attack):
			spriteAnimate.play(DIR_IDLE[direction_id])
		else :
			if bufferedDir.y >= 0: spriteAnimate.play("IDLEF")
			elif bufferedDir.y <= 0: spriteAnimate.play("IDLEB")
			elif bufferedDir.x >= 0: spriteAnimate.play("IDLER")
			elif bufferedDir.x <= 0: spriteAnimate.play("IDLEF")
	
		
	
	
	

func _walk(delta: float, dir : Vector2) -> void:
	stepCD+=delta
	if stepCD >= clamp(0.75 - SpeedMultiplier * 0.5, 0.2, 1):
		stepCD = 0
		step.play()
	var acc : float =  accel*delta*SpeedR*1.5
	Vel.x = move_toward(Vel.x, dir.x * SpeedR,acc) 
	Vel.y = move_toward(Vel.y, dir.y * SpeedR,acc) 
	
var DashDur : float = 0.0
@export var DashDurMax : float = 0.3
var DashCD : float = 0.0
@export var DashCDMax : float = 0.4
@export var SpeedDash : float = 900
var DashStyle : int = 0

func _dash(dir : Vector2)  -> void:
	
	dash.play()
	dash.get_stream_playback().switch_to_clip(DashStyle)
	light.color = Color.RED
	DashCD = DashCDMax
	DashDur = DashDurMax
	VelDash = dir * SpeedDash
	
@export var hpRecover : float = 20
var hpRecoverMult : float = 1
var hpDiff : float
var hpDiff2 : float 
func _health(delta)  -> void:
	hpDiff =  abs(hp - hpMax)
	hpDiff2 = abs((hp - hpMax)/100)
	#print(hpDiff, " ", hpDiff2)
	if hp == 0:
		HP.modulate.a = lerp(HP.modulate.a, 0.0, delta * 5 )
	elif hp > 0:
		HP.modulate.a = lerp(HP.modulate.a, 1.0, delta * hpDiff )
		hp=clamp(hp-delta*hpRecover*hpRecoverMult,0,hpMax)
	Heart.speed_scale = clamp(hp*0.05,1, 8)
	Heart.scale.x = clamp(hp*0.05,0, 1.5)
	Heart.scale.y = clamp(hp*0.05,0, 1.5)
	HPvienjette.modulate.a = lerp(HPvienjette.modulate.a, (1-hpDiff2), delta * hpDiff)
	barInsanity.scale.x = lerp(barInsanity.scale.x, clamp(hp/hpMax, 0.0, 1.0), delta * 100)
	
	
func _health_recover(heal : float)-> void:
	hp = clamp(hp - heal, 0, hpMax)
	#print(hp)
	#hp -= health
	
	
var iframes : float 
func _damage(damage : float, source : Node2D, dodgable : bool, parriable : bool):
	var vecToParried : Vector2 = Vector2.ZERO
	if is_instance_valid(source):
		vecToParried =  global_position - source.global_position 
	#await get_tree().process_frame
	if canRecieveDamage == true and damage !=0 and parryWindow <= 0:
		await get_tree().create_timer(0.1).timeout
		if parryWindow <= 0 and canRecieveDamage == true:
			hp += damage
			cam.shake(0.3, damage)
			hurt.play()
			style -= 1
		else:  _style(0)
	else:  _style(0)
	
	
	
	if parryWindow > 0:
		_parry(source, damage, vecToParried)
		_style(1)
	if  DashDur > 0:
		_style(1)
	


func _panic(delta : float):
	hp += panicArea.panicDamage*delta 

var style : int = 1
var styleMax : int = 10
func _style(add : int):
	style = clamp(style + add,1,styleMax)
	#print(style)
	DashStyle = style-1
	hpRecoverMult = style * 0.5
	

var dirToMouse : Vector2 = (get_global_mouse_position() - global_position).normalized()
var attackLenght 
var attackCD 
var attack : Node2D
var attackLanded : bool = false
@export var damage : float = 30
func _attack()  -> void:
	_interruptAction()
	swing.play()
	attack = projectile.instantiate()
	attack.look_at(dirToMouse)
	attack.damage = damage
	#get_viewport().get_mouse_position()
	add_child(attack)  
	
func _attackLand():
	if attackLanded == true:
		hitWeapon1.play()
		attackLanded = false
	cam.shake(0.3, 1)
	_style(1)
	_health_recover(damage * 0.2)
	Engine.time_scale = 0.1
	await get_tree().process_frame
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1
	
func _attacking(delta):	
	if attack.hitted == true:
		_attackLand()
		attackLanded = true

var parryWindowMax : float = 0.2
var parryWindow : float = 0.0
var parryCD : float = 0
var parryCDMax : float = 0.5
var velFromparry : int = 0
func _parry_try()  -> void:
	
	#print(velExtArr.size())
	parryCD = parryCDMax
	_interruptAction()
	parry2.play()
	parryWindow = parryWindowMax
func _parry(source, damage : float, dir : Vector2)  -> void:
	#print(velExtArr.size())
	parry.play()
	var spark : GPUParticles2D = particleSpark.instantiate()
	spark.emitting = true
	collision.add_child(spark)  
	parryCD = 0
	cam.shake(0.3, 30)
	if  is_instance_valid(source) and source is Node2D:
		spark.look_at(source.global_position)
		if velFromparry <= 0: 
			VelocityAutoload.add_external_velocity(self,dir,damage*20,0.2)
			velFromparry+=1
		if source is EnemyChar:
			_health_recover(source.panicDamage*0.5)
	_health_recover( damage* 0.5)
	
	
