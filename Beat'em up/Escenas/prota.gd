extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	$Area2D.get_overlapping_areas()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif velocity.x == 0 and Input.is_action_pressed("punch"):
		animated_sprite_2d.play("punch")
	elif  direction > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("walk")
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
	

	
	move_and_slide()
