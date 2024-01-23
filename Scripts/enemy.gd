extends CharacterBody3D

var PLAYER = null

@export var SPEED = 4.0
@export var HP = 10

@export var PLAYER_PATH : NodePath

# boolean switches
var isAggro: bool = false
var playerDetected: bool = false


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
	if not isAggro:
		$Control/Katana.hide()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = true
	
	look_at(Vector3(PLAYER.global_position.x, global_position.y, PLAYER.global_position.z), Vector3.UP)
	
	move_and_slide()
	
	if HP <= 0:
		PLAYER.STAMINA = PLAYER.MAX_STAMINA
		PLAYER.killCount += 1
		queue_free()
		


func _on_hit_box_area_entered(area):
	if area.is_in_group('playerSword'):
		HP -= (PLAYER.DAMAGE * PLAYER.dmgMultiplier)
		PLAYER.STAMINA += PLAYER.DAMAGE
		$Blood.show()
		$BloodTimer.start()


func _on_player_checker_body_entered(body):
	if body.is_in_group('player'):
		isAggro = true
		playerDetected = true


func _on_sword_checker_area_entered(area):
	if area.is_in_group('playerSword'):
		isAggro = true
		playerDetected = true


func _on_player_checker_body_exited(body):
	if body.is_in_group('player') and playerDetected:
		playerDetected = false
		$AggroTimer.start()
	


func _on_aggro_timer_timeout():
	if not playerDetected:
		isAggro = false


func _on_blood_timer_timeout():
	$Blood.hide()
