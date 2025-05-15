extends Control

signal transition_done(success: bool)

@onready var fade := $fade
@onready var dia_label := $dayInfo/diaLabel
@onready var cuota_label := $dayInfo/cuotaLabel
@onready var money_label := $dayInfo/moneyLabel
@onready var resultado_label := $dayInfo/resultLabel
@onready var continuar_btn := $dayInfo/continuarBtn

var jugador_tiene_dinero := true

func setup(dia: int, dinero: int, cuota: int, tiene_dinero: bool):
	dia_label.text = "Día %d" % dia
	cuota_label.text = "Cuota diaria: $%d" % cuota
	money_label.text = "Dinero disponible: $%d" % dinero
	jugador_tiene_dinero = tiene_dinero

	if not tiene_dinero:
		resultado_label.text = "💀 PERDISTE..."
		continuar_btn.text = "Salir"
	else:
		resultado_label.text = ""
		continuar_btn.text = "Continuar"

	# Fundido a negro
	fade.color.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 0.0, 1.5)

func _on_continuarBtn_pressed():
	if jugador_tiene_dinero:
		emit_signal("transition_done", true)
		queue_free()
	else:
		get_tree().quit()
