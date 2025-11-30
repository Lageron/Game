extends Projectile
@onready var ContactDamage : EnemyDamageOnContact = $ContactDamage
@onready var Sprite  : Sprite2D = $rot_point/Weapon
@onready var rotPoint  : Node2D = $rot_point
@onready var slash  : AnimatedSprite2D = $Slash


@export var hitEffect  : PackedScene 

@export var size : Vector2 = Vector2(256,256)
var timeToLive : float = 0
var timeToLiveMax : float = 0.3

var angleShovel : float = 0

var hitted : bool

func _ready() -> void:
	ContactDamage.friendly = true
	ContactDamage.get_damage = func(): return damage 
	slash.play()
func _physics_process(delta: float) -> void:
	rotPoint.rotation = angleShovel
	#rotPoint.rotate(angleShovel)
	#rotPoint.rotation = lerp(rotPoint.rotation,rotPoint.rotation + angleShovel, delta) 
	#print(angleShovel)
	"
	timeToLive+= delta
	if timeToLive > timeToLiveMax:
		queue_free()
	"
	
	


func _on_slash_animation_finished() -> void:
	queue_free()


func _on_slash_frame_changed() -> void:
	angleShovel += 45


func _on_contact_damage_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body is EnemyChar:
		hitted = ContactDamage.hitted 
		var impact : Node2D = hitEffect.instantiate()
		impact.rotation = rotation
		body.add_child(impact)
		
		
		
