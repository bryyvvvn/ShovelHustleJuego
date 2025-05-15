extends Control

signal transition_done(success: bool)

@onready var fade := $fade
@onready var dia_label := $dayInfo/diaLabel
@onready var cuota_label := $dayInfo/cuotaLabel
@onready var resultado_label := $dayInfo/resultLabel
@onready var continuar_btn := $dayInfo/continuarBtn
@onready var money_label := $dayInfo/dineroAnimado/moneyLabel

var jugador_tiene_dinero := true

#para animación
var dinero_actual := 0
var dinero_final := 0

func setup(dia: int, dinero: int, cuota: int, tiene_dinero: bool):
	dia_label.text = "Día %d" % dia
	cuota_label.text = "Cuota diaria: $%d" % cuota
	
	dinero_actual = dinero
	dinero_final = max(dinero - cuota, 0)
	
	money_label.text = "$%d" % dinero_actual
	animar_descuento()
	
	jugador_tiene_dinero = tiene_dinero

	if not tiene_dinero:
		resultado_label.text = "💀 PERDISTE..."
		continuar_btn.text = "Salir"
	else:
		resultado_label.text = ""
		continuar_btn.text = "Continuar"

	# fundido a negro
	fade.color.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 0.0, 1.5)

func _on_continuarBtn_pressed():
	if jugador_tiene_dinero:
		emit_signal("transition_done", true)
		queue_free()
	else:
		get_tree().quit()
		
func animar_descuento():
	var tween = create_tween()
	tween.set_parallel(false)  

	var duracion := 1.5
	tween.tween_method(
		func(valor): money_label.text = "$%d" % valor,
		dinero_actual, dinero_final, duracion
	)
