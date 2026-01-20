extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var moves_label: Label = $VBoxContainer/MovesLabel
@onready var captured_label: Label = $VBoxContainer/CapturedLabel
@onready var restart_button: Button = $VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton

func _ready():
	setup_theme()
	update_stats()
	connect_signals()

func setup_theme():
	var theme = Theme.new()
	
	# Victory button styling
	var victory_style = StyleBoxFlat.new()
	victory_style.bg_color = Color("#10b981") # Emerald green
	victory_style.corner_radius_top_left = 8
	victory_style.corner_radius_top_right = 8
	victory_style.corner_radius_bottom_left = 8
	victory_style.corner_radius_bottom_right = 8
	
	var victory_hover = victory_style.duplicate()
	victory_hover.bg_color = Color("#34d399") # Lighter green
	
	theme.set_stylebox("normal", "Button", victory_style)
	theme.set_stylebox("hover", "Button", victory_hover)
	theme.set_color("font_color", "Button", Color.WHITE)
	
	# Label styling
	theme.set_color("font_color", "Label", Color("#e2e8f0"))
	
	theme = theme

func update_stats():
	if score_label:
		score_label.text = "Final Score: %d" % Global.score
	if high_score_label:
		high_score_label.text = "High Score: %d" % Global.high_score
		high_score_label.visible = true
	if moves_label:
		moves_label.text = "Moves Made: %d" % Global.moves_count
	if captured_label:
		captured_label.text = "Pieces Captured: %d" % Global.pieces_captured

func connect_signals():
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()