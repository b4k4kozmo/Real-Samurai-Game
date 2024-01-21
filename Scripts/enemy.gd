extends CharacterBody3D

var PLAYER = null

@export var SPEED = 4.0
@export var HP = 10

@export var PLAYER_PATH : NodePath
@onready var nav_agent = $NavigationAgent3D

# boolean switches
var isAggro: bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	PLAYER = get_node(PLAYER_PATH)
	$Blood.hide()
	$Control/Katana.hide()
	$Control/Katana/SlashArea/CollisionShape3D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	velocity = Vector3.ZERO

	var direction = Vector3.ZERO
	direction = (PLAYER.position - position).normalized()
	if direction and isAggro:
		$Control/Katana.show()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = false
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


func _on_player_checker_body_entered(body):
	if body.is_in_group('player'):
		isAggro = true


func _on_sword_checker_area_entered(area):
	if area.is_in_group('playerSword'):
		isAggro = true
