extends Node2D

@onready var camara = $mago_malvado/Camera2D
@onready var mago = $mago_malvado
@onready var borde2 = $borde2
@onready var borde3 = $borde3
@onready var borde4 = $borde4
@onready var zona1 = $zona1
@onready var zona2 = $zona2
@onready var zona3 = $zona3
@onready var siguiente_nivel = $siguiente_nivel

var zonas = [
	{"limite_izquierdo": 0,    "limite_derecho": 1150, "limite_techo": 0, "enemigos": "enemigos1"},
	{"limite_izquierdo": 1150, "limite_derecho": 2250, "limite_techo": 0, "enemigos": "enemigos2"},
	{"limite_izquierdo": 2250, "limite_derecho": 3350, "limite_techo": 0, "enemigos": "enemigos3"},
]
var zona_actual = 0
var camara_bloqueada = false

func _ready() -> void:
	$zona1.body_entered.connect(_on_zona1_entered)
	$zona2.body_entered.connect(_on_zona2_entered)
	$zona3.body_entered.connect(_on_zona3_entered)
	siguiente_nivel.body_entered.connect(_on_siguiente_nivel_entered)
	bloquear_camara(0)


func _on_siguiente_nivel_entered(body: Node2D) -> void:
	if body.name == "mago_malvado":
		get_tree().change_scene_to_file("res://Beat'em up/Escenas/ganaste.tscn")

func _on_zona1_entered(body):
	if body.name == "mago_malvado":
		var contenedor = get_node("enemigos1")
		if contenedor.get_child_count() == 0:
			bloquear_camara(1)
			borde2.queue_free()
			zona1.queue_free()
		else:
			print("¡Todavía quedan enemigos!")

func _on_zona2_entered(body):
	if body.name == "mago_malvado":
		var contenedor = get_node("enemigos2")  
		if contenedor.get_child_count() == 0:
			bloquear_camara(2)
			borde3.queue_free()
			zona2.queue_free()
		else:
			print("¡Todavía quedan enemigos!")

func _on_zona3_entered(body):
	if body.name == "mago_malvado":
		var contenedor = get_node("enemigos3")  
		if contenedor.get_child_count() == 0:
			bloquear_camara(2)
			borde4.queue_free()
			zona3.queue_free()
		else:
			print("¡Todavía quedan enemigos!")


func bloquear_camara(zona: int):
	zona_actual = zona
	camara_bloqueada = true
	camara.limit_left = zonas[zona]["limite_izquierdo"]
	camara.limit_right = zonas[zona]["limite_derecho"]
	camara.limit_top = zonas[zona]["limite_techo"]
	print("Cámara bloqueada en zona ", zona)

func chequear_enemigos():
	await get_tree().process_frame
	var contenedor = get_node(zonas[zona_actual]["enemigos"])
	if contenedor.get_child_count() == 0:
		desbloquear_camara()

func desbloquear_camara():
	camara_bloqueada = false
	print("¡Zona limpia!")
	if zona_actual + 1 < zonas.size():
		camara.limit_right = zonas[zona_actual + 1]["limite_derecho"]
