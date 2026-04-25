extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -490.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_ataque = $Area2D

var salud_maxima = 100
var salud_actual
var puede_golpear = true
var mirando_derecha = true

func _ready() -> void:
	salud_actual = salud_maxima
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("punch") and is_on_floor() and puede_golpear:
		golpear()

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
		mirando_derecha = true
		area_ataque.position.x = abs(area_ataque.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		mirando_derecha = false
		area_ataque.position.x = -abs(area_ataque.position.x)
	
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
	
func golpear():
	print("golpeando")
	puede_golpear = false
	
	var areas_cercanas = area_ataque.get_overlapping_areas()
	for area in areas_cercanas:
		var enemigo = area.get_parent()
		if enemigo.has_method("recibir_daño"):
			enemigo.recibir_daño(50)
	
	await get_tree().create_timer(0.5).timeout
	puede_golpear = true	
	
func _on_animation_finished():
	if animated_sprite_2d.animation == "punch":
		animated_sprite_2d.play("idle")

func recibir_daño(daño: int):
	salud_actual -= daño
	if salud_actual <= 0:
		queue_free()
