extends Line2D

@onready var raycast : RayCast2D = $RayCast2D
@export var target : Vector2 
@export var maxDist : float = 2000

func _updateRay():
	points[0] = Vector2.ZERO
	raycast.target_position.x = maxDist
	raycast.force_raycast_update()
	
	
