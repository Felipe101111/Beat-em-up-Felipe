extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var velocidad = 200
var direccion = 1  # 1 = derecha, -1 = izquierda

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x += velocidad * direccion * delta
	animated_sprite_2d.play("movimiento")

func _on_body_entered(body):
	if body.has_method("recibir_Daño"):
		body.recibir_Daño()
		animated_sprite_2d.play("explosion")

func _on_animated_sprite_2d_animation_finished():
	queue_free()  # ⬅️ DESAPARECE AL TERMINAR ANIMACIÓN
