extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var prota: CharacterBody2D = $"../prota"


func _physics_process(delta: float) -> void:

	var dirrecion = (prota.global_position - global_position).normalized()
	var distancia = global_position.distance_to(prota.global_position)
	if distancia >75:
		if prota.global_position.x < global_position.x :
			velocity=dirrecion*SPEED
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = true
		else :
			velocity=dirrecion*SPEED
			animated_sprite_2d.play("walk")
	else:
		velocity = Vector2(0,0)
		animated_sprite_2d.play("ataque")
		
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
