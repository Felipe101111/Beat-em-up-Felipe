extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -490.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_ataque = $Area2D
@onready var corazon1 = $CanvasLayer/Sprite2D
@onready var corazon2 =$CanvasLayer/Sprite2D2
@onready var corazon3 = $CanvasLayer/Sprite2D3
@onready var corazon4 = $CanvasLayer/Sprite2D4
@onready var corazon5 = $CanvasLayer/Sprite2D5
@onready var area_pies = $piso

var puede_recibir_daño_pincho = true
var salud_maxima = 5
var salud_actual
var puede_golpear = true
var mirando_derecha = true
var atacando = false

func _ready() -> void:
	salud_actual = salud_maxima
	area_pies.body_entered.connect(_on_pies_body_entered)
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
		atacando = false
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
	elif atacando:
		pass
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
	puede_golpear = false
	atacando = true
	animated_sprite_2d.play("ataque")
	
	if velocity.x == 0:
		var areas_cercanas = area_ataque.get_overlapping_areas()
		for area in areas_cercanas:
			if area.name == "areaDaño":
				var enemigo = area.get_parent()
				if enemigo.has_method("recibir_daño"):
					if is_instance_valid(enemigo):
						enemigo.recibir_daño(50)

	await get_tree().create_timer(1.0).timeout
	puede_golpear = true
	atacando = false
	
func _on_animation_finished():
	if animated_sprite_2d.animation == "punch":
		atacando = false 
		animated_sprite_2d.play("idle")
	elif animated_sprite_2d.animation == "jump":
		animated_sprite_2d.play("idle")

func recibir_Daño():
	salud_actual -= 1
	
	if salud_actual == 4:
		corazon5.visible = false
	elif salud_actual == 3:
		corazon4.visible = false
	elif salud_actual == 2:
		corazon3.visible = false
	elif salud_actual == 1:
		corazon2.visible = false
	elif salud_actual <= 0:
		corazon1.visible = false
		set_physics_process(false)
		animated_sprite_2d.play("muerte")
		await animated_sprite_2d.animation_finished
		get_tree().call_deferred("change_scene_to_file", "res://Beat'em up/Escenas/perdiste.tscn")
		
func _on_pies_body_entered(body):
	if body is TileMapLayer and body.name == "pinchos":
		if puede_recibir_daño_pincho:
			recibir_Daño()
			puede_recibir_daño_pincho = false
			await get_tree().create_timer(1.0).timeout
			puede_recibir_daño_pincho = true
