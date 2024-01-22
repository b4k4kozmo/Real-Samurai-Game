extends CharacterBody3D

var SPEED
var HP
var STAMINA
var DAMAGE

# Phyisics variables
@export var WALK_SPEED = 10.0
@export var SPRINT_SPEED = 20.0
@export var SLOW_SPEED = 2.0
@export var JUMP_VELOCITY = 5.5

# Player stats
@export var MAX_HP = 10
@export var MAX_STAMINA = 60
@export var WALK_DAMAGE = 2
@export var SPRINT_DAMAGE = 5

# onreadys
@onready var healthBar = $CanvasLayer/HealthBar
@onready var staminaBar = $CanvasLayer/StaminaBar

# Booleans
var isAttacking = false
var isSprinting = false




# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	HP = MAX_HP
	STAMINA = MAX_STAMINA
	DAMAGE = WALK_DAMAGE
	$Blood.hide()
	print_debug(HP , STAMINA , DAMAGE)
	healthBar.init_health(HP)
	staminaBar.init_health(STAMINA)

func _physics_process(delta):
	# Add the gravity.
	velocity.y -= gravity * delta
	

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and STAMINA >= 3:
		velocity.y = JUMP_VELOCITY
		STAMINA -= 3
		staminaBar.health = STAMINA

	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		if STAMINA > 0:
			SPEED = SPRINT_SPEED
			DAMAGE = SPRINT_DAMAGE
			isSprinting = true
			STAMINA -= .1
			staminaBar.health = STAMINA
		else:
			SPEED = SLOW_SPEED
	else:
		if STAMINA >= 3:
			SPEED = WALK_SPEED
		else: 
			SPEED = SLOW_SPEED
		DAMAGE = WALK_DAMAGE
		isSprinting = false
	# Handle Attack.
	if Input.is_action_pressed("attack") and STAMINA > 0:
		isAttacking = true
		$Control/Katana.show()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = false
		STAMINA -= .1
		staminaBar.health = STAMINA
		# print_debug(STAMINA)
	elif Input.is_action_just_released("attack"):
		isAttacking = false
	elif not isAttacking:
		$Control/Katana.hide()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = true
	elif STAMINA <= 0:
		$Control/Katana.hide()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = true
		
	if not isAttacking and not isSprinting:
		STAMINA += .1
		staminaBar.health = STAMINA
		if STAMINA >= MAX_STAMINA:
			STAMINA = MAX_STAMINA
			staminaBar.health = STAMINA
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	$Control.look_at(global_position + direction, Vector3.UP)
	move_and_slide()
	
	if HP <= 0:
		die()


func _on_hit_box_area_entered(area):
	if area.is_in_group('sword'):
		HP -= 3
		$Blood.show()
		healthBar.health = HP
		print_debug(HP)
		
func die():
	$Blood.hide()
	print_debug('You have died')
	HP = MAX_HP
	STAMINA = MAX_STAMINA
	healthBar.init_health(HP)
	staminaBar.init_health(STAMINA)
