extends Control

signal transition_done(success: bool)

@onready var fade := $fade
@onready var dia_label := $dayInfo/diaLabel
@onready var cuota_label := $dayInfo/cuotaLabel
@onready var resultado_label := $dayInfo/resultLabel
@onready var continuar_btn := $dayInfo/continuarBtn
@onready var money_label := $dayInfo/dineroAnimado/moneyLabel
@onready var coin := $TextureRect
@onready var robo := $dayInfo/robo

var jugador_tiene_dinero := true

#para animación
var dinero_actual := 0
var dinero_final := 0

func _ready():
	pass
	
func setup(dia: int, dinero: int, cuota: int, tiene_dinero: bool, perdida: int):
	dia_label.text = "Día %d" % dia
	cuota_label.text = "Cuota diaria: $%d" % cuota
	
	dinero_actual = dinero
	dinero_final = max(dinero - cuota, 0)
	
	money_label.text = "$%d" % dinero_actual
	#animar_descuento()
	
	jugador_tiene_dinero = tiene_dinero

	if not tiene_dinero:
		resultado_label.text = "💀 PERDISTE..."
		continuar_btn.text = "Salir"
	else:
		resultado_label.text = ""
		continuar_btn.text = "Continuar"
	if perdida > 0:
		robo.text = "Te han robado $%d monedas" % perdida
	else:
		robo.text = ""
	# fundido a negro
	fade.color.a = 0
	dia_label.modulate.a = 0
	cuota_label.modulate.a = 0
	resultado_label.modulate.a = 0
	continuar_btn.modulate.a = 0
	money_label.modulate.a = 0
	animar_descuento()
	coin.modulate.a = 0
	robo.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 1.5)
	tween.tween_property(dia_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(cuota_label, "modulate:a", 1.0, 1.5)
	if perdida > 0:
		tween.tween_property(robo, "modulate:a", 1.0, 1.5)
	tween.tween_property(money_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(coin,"modulate:a",1.0,0.8)
	tween.tween_property(resultado_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(continuar_btn, "modulate:a", 1.0, 1.5)
	
func animar_descuento():
	var tween = create_tween()
	tween.set_parallel(false)  

	var duracion := 5
	tween.tween_method(
		func(valor): money_label.text = "$%d" % valor,
		dinero_actual, dinero_final, duracion
	)

var menu_scene := preload("res://Scenes/Menu/Menu.tscn")
func _on_continuar_Btn_pressed() -> void:
	if jugador_tiene_dinero:
		emit_signal("transition_done", true)
		visible = false
		print("Nodo que ejecuta el cambio:", self)
		print("Árbol de escenas (get_tree):", get_tree())
	
		if get_tree() == null:
			print("Error: get_tree() es null")
		else:
			print("Árbol de escenas OK")
	else:
		emit_signal("transition_done", false)
		visible = false
