extends CharacterBody3D

var SPEED
var HP
var STAMINA
var DAMAGE
var direction

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
@onready var victoryTimer = $VictoryTimer

# Booleans
var isAttacking = false
var isSprinting = false
var canMove = true
var isVulnerable = false
var isKnocked = false
#var isVictory = false

# Counters
var killCount = 0
var dmgMultiplier = 1
var jumpCount = 0
var maxJump = 2

#constant variables
var killsNeeded = 9 #change this number to match number of enemies




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
	$CanvasLayer/ColorRect.hide()

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()

func restart():
	get_tree().reload_current_scene()

func _physics_process(delta):
	
	# Add the gravity.
	velocity.y -= gravity * delta
	
	# Handle meditate
	if Input.is_action_pressed("meditate") and STAMINA > 0:
		canMove = false
		isVulnerable = true
		HP += .01
		STAMINA -= 0.1
		healthBar.health = HP
		staminaBar.health = STAMINA
		dmgMultiplier += .01
		print_debug(dmgMultiplier)
	if Input.is_action_just_released("meditate"):
		canMove = true
		isVulnerable = false
		

	# Handle jump.
	if is_on_floor():
		jumpCount = 0
	if Input.is_action_just_pressed("jump") and jumpCount < maxJump and STAMINA >= 3 and canMove:
		jumpCount += 1
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
		dmgMultiplier = 1
	elif not isAttacking:
		$Control/Katana.hide()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = true
	elif STAMINA <= 0:
		$Control/Katana.hide()
		$Control/Katana/SlashArea/CollisionShape3D.disabled = true
		
	if not isAttacking and not isSprinting and canMove:
		STAMINA += .1
		staminaBar.health = STAMINA
		if STAMINA >= MAX_STAMINA:
			STAMINA = MAX_STAMINA
			staminaBar.health = STAMINA
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and canMove and not isKnocked:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		$Control.look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	
	move_and_slide()
	
	if HP <= 0:
		die()
	
	$CanvasLayer/Label4.text = str(killCount)
	
	# triggers victory screens
	if killCount >= killsNeeded:
		if victoryTimer.is_stopped():
			victoryTimer.start()


func _on_hit_box_area_entered(area):
	if area.is_in_group('sword'):
		if not isVulnerable:
			isKnocked = true
			HP -= 3
			velocity.x = area.get_parent().get_parent().get_parent().direction.x * 100
			velocity.z = area.get_parent().get_parent().get_parent().direction.z * 100
			$KnockTimer.start()
		else:
			HP = -1
		$Blood.show()
		healthBar.health = HP
		$BloodTimer.start()
		
func die():
	$Blood.hide()
	BackgroundMusic.stop()
	$CanvasLayer/ColorRect.show()


func _on_blood_timer_timeout():
	$Blood.hide()


func _on_knock_timer_timeout():
	isKnocked = false




func _on_victory_timer_timeout():
	killCount = 0
	$CanvasLayer/ColorRect/Label.text = '[center]YOU WIN![/center]'
	die()
