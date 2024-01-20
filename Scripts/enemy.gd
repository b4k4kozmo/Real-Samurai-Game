extends CharacterBody3D

var PLAYER = null

@export var SPEED = 4.0
@export var HP = 10

@export var PLAYER_PATH : NodePath
@onready var nav_agent = $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready():
	PLAYER = get_node(PLAYER_PATH)
	$Blood.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(PLAYER.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	var direction = Vector3.ZERO
	direction = (PLAYER.position - position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	look_at(Vector3(PLAYER.global_position.x, global_position.y, PLAYER.global_position.z), Vector3.UP)
	
	move_and_slide()
	
	if HP <= 0:
		PLAYER.STAMINA = PLAYER.MAX_STAMINA
		queue_free()


func _on_hit_box_area_entered(area):
	if area.is_in_group('playerSword'):
		HP -= PLAYER.DAMAGE
		$Blood.show()
		print_debug(HP)
