extends CharacterBody2D

const SPEED = 150.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var areaDeteccion = $areaDeteccion
@onready var areaAtaque = $areaAtaque

var prota = null
var en_rango = false
var puede_atacar = true
var distancia_ataque = 100 
var atacando = false 
var dano_aplicado = false  

func _ready() -> void:
	areaDeteccion.area_entered.connect(_on_area_deteccion_entered)
	areaDeteccion.area_exited.connect(_on_area_deteccion_exited)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	if atacando and prota:
		velocity = Vector2.ZERO
		var distancia = global_position.distance_to(prota.global_position)
		
		if distancia > distancia_ataque + 30:
			atacando = false
			puede_atacar = true
			dano_aplicado = false  
			animated_sprite_2d.play("idle")
		else:
			move_and_slide()
	
	if prota and en_rango:
		var distancia = global_position.distance_to(prota.global_position)
		
		if distancia > distancia_ataque:
			var direccion = (prota.global_position - global_position).normalized()
			velocity = direccion * SPEED
			animated_sprite_2d.play("walk")
			
			if direccion.x < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
		else:
			velocity = Vector2.ZERO
			if puede_atacar and not atacando:
				atacar()
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")
	
	move_and_slide()

func _on_area_deteccion_entered(area):
	if area.get_parent().name == "prota":
		prota = area.get_parent()
		en_rango = true

func _on_area_deteccion_exited(area):
	if area.get_parent().name == "prota":
		prota = null
		en_rango = false
		atacando = false
		dano_aplicado = false

func atacar():
	puede_atacar = false
	atacando = true
	dano_aplicado = false
	animated_sprite_2d.play("ataque")
	await get_tree().create_timer(0.80).timeout 
	puede_atacar = true
	atacando = false
	
	if not dano_aplicado and prota:
		var distancia = global_position.distance_to(prota.global_position)
		if distancia <= distancia_ataque + 20:
			prota.recibir_daño(50)
			dano_aplicado = true
	
	await animated_sprite_2d.animation_finished
	
	await get_tree().create_timer(3).timeout
	puede_atacar = true
	atacando = false 

func _on_animation_finished():
	if animated_sprite_2d.animation == "ataque":
		animated_sprite_2d.play("idle")
