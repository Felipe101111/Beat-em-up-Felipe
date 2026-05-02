extends CharacterBody2D
const SPEED = 150.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var areaDeteccion = $areaDeteccion
@onready var areaAtaque = $areaAtaque
var mago_malvado = null
var en_rango = false
var en_rango_ataque = false
var puede_atacar = true
var atacando = false 
var dano_aplicado = false
@export var salud_maxima = 200
var salud_actual 
var recibiendo_daño = false

func _ready() -> void:
	areaDeteccion.area_entered.connect(_on_area_deteccion_entered)
	areaDeteccion.area_exited.connect(_on_area_deteccion_exited)
	areaAtaque.body_entered.connect(_on_area_ataque_body_entered)
	areaAtaque.body_exited.connect(_on_area_ataque_body_exited)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	salud_actual = salud_maxima
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if atacando or recibiendo_daño:
			velocity = Vector2.ZERO
			move_and_slide()
			return
			
		if mago_malvado and en_rango:
			if not en_rango_ataque:
				var direccion = (mago_malvado.global_position - global_position).normalized()
				velocity = direccion * SPEED
				animated_sprite_2d.play("walk")
				if direccion.x < 0:
					animated_sprite_2d.flip_h = true
					areaAtaque.position.x = -abs(areaAtaque.position.x)
				else:
					animated_sprite_2d.flip_h = false
					areaAtaque.position.x = abs(areaAtaque.position.x)
			else:
				velocity = Vector2.ZERO
				if puede_atacar:
					atacar()
		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
		
	move_and_slide()

func _on_area_deteccion_entered(area):
	if area.name == "areadaño":
		mago_malvado = area.get_parent()
		en_rango = true

func _on_area_deteccion_exited(area):
	if area.name == "areadaño":
		mago_malvado = null
		en_rango = false
		atacando = false
		dano_aplicado = false

func _on_area_ataque_body_entered(body):
	if body.name == "mago_malvado":
		en_rango_ataque = true

func _on_area_ataque_body_exited(body):
	if body.name == "mago_malvado":
		en_rango_ataque = false
		if atacando:
			atacando = false
			puede_atacar = true

func atacar():
	puede_atacar = false
	atacando = true
	dano_aplicado = false
	animated_sprite_2d.play("ataque")
	
	await get_tree().create_timer(0.8).timeout
	puede_atacar = true
	atacando = false
	
	if en_rango_ataque and mago_malvado and !dano_aplicado:
		mago_malvado.recibir_daño()
		dano_aplicado = true
	
	await get_tree().create_timer(3).timeout
	puede_atacar = true
	atacando = false 

func _on_animation_finished():
	if animated_sprite_2d.animation == "ataque":
		animated_sprite_2d.play("idle" )
		
func recibir_daño(daño: int):
	salud_actual -= daño
	if salud_actual <= 0:
		set_physics_process(false)
		puede_atacar = false
		atacando = false
		velocity = Vector2.ZERO
		areaDeteccion.monitoring = false
		areaAtaque.monitoring = false
		animated_sprite_2d.play("dead")
		await animated_sprite_2d.animation_finished
		get_tree().current_scene.chequear_enemigos()
		queue_free()
	else:
		recibiendo_daño = true
		atacando = true
		puede_atacar = false
		velocity = Vector2.ZERO
		animated_sprite_2d.play("take_hit") 
		await animated_sprite_2d.animation_finished
		recibiendo_daño = false
		atacando = false
		puede_atacar = true
