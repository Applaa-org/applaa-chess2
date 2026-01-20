extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var close_button: Button = $VBoxContainer/CloseButton
@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameContainer/PlayerNameInput
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var instructions_label: RichTextLabel = $VBoxContainer/InstructionsLabel

func _ready():
	# Set up modern styling
	setup_theme()
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)
	player_name_input.text_submitted.connect(_on_name_submitted)
	
	# Initialize high score display
	if high_score_label:
		high_score_label.text = "High Score: 0"
		high_score_label.visible = true
	
	# Load game data
	Global.load_game_data()

func setup_theme():
	var theme = Theme.new()
	
	# Button styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color("#6366f1") # Electric blue
	button_style.corner_radius_top_left = 8
	button_style.corner_radius_top_right = 8
	button_style.corner_radius_bottom_left = 8
	button_style.corner_radius_bottom_right = 8
	
	var button_hover = button_style.duplicate()
	button_hover.bg_color = Color("#818cf8") # Lighter blue
	
	var button_pressed = button_style.duplicate()
	button_pressed.bg_color = Color("#4f46e5") # Darker blue
	
	theme.set_stylebox("normal", "Button", button_style)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	
	# Text colors
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color.WHITE)
	
	# Label styling
	theme.set_color("font_color", "Label", Color("#e2e8f0")) # Light gray
	
	# LineEdit styling
	var line_edit_style = StyleBoxFlat.new()
	line_edit_style.bg_color = Color("#1e293b") # Dark slate
	line_edit_style.corner_radius_top_left = 6
	line_edit_style.corner_radius_top_right = 6
	line_edit_style.corner_radius_bottom_left = 6
	line_edit_style.corner_radius_bottom_right = 6
	line_edit_style.border_width_left = 1
	line_edit_style.border_width_right = 1
	line_edit_style.border_width_top = 1
	line_edit_style.border_width_bottom = 1
	line_edit_style.border_color = Color("#475569") # Border
	
	theme.set_stylebox("normal", "LineEdit", line_edit_style)
	theme.set_color("font_color", "LineEdit", Color.WHITE)
	
	# Apply theme
	theme = theme

func _on_start_pressed():
	if player_name_input.text.strip_edges() != "":
		Global.player_name = player_name_input.text.strip_edges()
	
	Global.reset_score()
	Global.set_game_state(Global.GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed():
	get_tree().quit()

func _on_name_submitted(text: String):
	if text.strip_edges() != "":
		Global.player_name = text.strip_edges()
		start_button.grab_focus()