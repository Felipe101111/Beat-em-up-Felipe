extends Node2D

@onready var contenedor_enemigos = $Node2D
@onready var pared_area = $borde2/Area2D
var enemigos_muertos = false

func _ready() -> void:
	pared_area.body_entered.connect(_on_pared_body_entered)

func _process(delta: float) -> void:
	pass

func chequear_enemigos():
	await get_tree().process_frame
	if contenedor_enemigos.get_child_count() == 0:
		enemigos_muertos = true
		$borde2/CollisionShape2D.disabled = true

func _on_pared_body_entered(body):
	if body.name == "mago_malvado" and enemigos_muertos:
		siguiente_nivel()

func siguiente_nivel():
	get_tree().change_scene_to_file("res://Beat'em up/Escenas/nivel_1_2.tscn")  # ⬅️ Tu ruta
