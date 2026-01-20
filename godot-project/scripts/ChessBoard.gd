extends Node2D

const BOARD_SIZE = 8
const SQUARE_SIZE = 80

@onready var board_container: Control = $BoardContainer
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var moves_label: Label = $UI/TopBar/MovesLabel
@onready var turn_label: Label = $UI/TopBar/TurnLabel
@onready var high_score_label: Label = $UI/TopBar/HighScoreLabel

var board: Array = []
var selected_piece: ChessPiece = null
var selected_square: Vector2i = Vector2i(-1, -1)
var possible_moves: Array = []
var current_turn: String = "white"

# Piece types
enum PieceType { PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING }

func _ready():
	setup_board()
	setup_ui()
	Global.set_game_state(Global.GameState.PLAYING)

func setup_board():
	# Initialize 8x8 board
	board = []
	for i in range(BOARD_SIZE):
		board.append([])
		for j in range(BOARD_SIZE):
			board[i].append(null)
	
	# Place pieces in starting positions
	setup_starting_pieces()

func setup_starting_pieces():
	# Place pawns
	for i in range(BOARD_SIZE):
		board[1][i] = ChessPiece.new(PieceType.PAWN, "black", Vector2i(1, i))
		board[6][i] = ChessPiece.new(PieceType.PAWN, "white", Vector2i(6, i))
	
	# Place other pieces
	var back_row = [PieceType.ROOK, PieceType.KNIGHT, PieceType.BISHOP, PieceType.QUEEN, 
					PieceType.KING, PieceType.BISHOP, PieceType.KNIGHT, PieceType.ROOK]
	
	for i in range(BOARD_SIZE):
		board[0][i] = ChessPiece.new(back_row[i], "black", Vector2i(0, i))
		board[7][i] = ChessPiece.new(back_row[i], "white", Vector2i(7, i))

func setup_ui():
	if score_label:
		score_label.text = "Score: %d" % Global.score
	if moves_label:
		moves_label.text = "Moves: %d" % Global.moves_count
	if turn_label:
		turn_label.text = "Turn: White"
	if high_score_label:
		high_score_label.text = "High Score: %d" % Global.high_score
		high_score_label.visible = true

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_local_mouse_position()
		var board_pos = screen_to_board(mouse_pos)
		
		if is_valid_square(board_pos):
			handle_square_click(board_pos)
	
	# ESC to pause/return to menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func screen_to_board(screen_pos: Vector2) -> Vector2i:
	var board_start = Vector2(100, 100) # Adjust based on your layout
	var board_x = int((screen_pos.x - board_start.x) / SQUARE_SIZE)
	var board_y = int((screen_pos.y - board_start.y) / SQUARE_SIZE)
	return Vector2i(board_y, board_x)

func is_valid_square(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE

func handle_square_click(pos: Vector2i):
	var piece = board[pos.x][pos.y]
	
	if selected_piece == null:
		# Select a piece
		if piece != null and piece.color == current_turn:
			selected_piece = piece
			selected_square = pos
			possible_moves = get_possible_moves(piece, pos)
	else:
		# Try to move or capture
		if pos in possible_moves:
			move_piece(selected_square, pos)
		else:
			# Deselect or select new piece
			if piece != null and piece.color == current_turn:
				selected_piece = piece
				selected_square = pos
				possible_moves = get_possible_moves(piece, pos)
			else:
				selected_piece = null
				selected_square = Vector2i(-1, -1)
				possible_moves = []

func get_possible_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	
	match piece.type:
		PieceType.PAWN:
			moves = get_pawn_moves(piece, pos)
		PieceType.ROOK:
			moves = get_rook_moves(piece, pos)
		PieceType.KNIGHT:
			moves = get_knight_moves(piece, pos)
		PieceType.BISHOP:
			moves = get_bishop_moves(piece, pos)
		PieceType.QUEEN:
			moves = get_queen_moves(piece, pos)
		PieceType.KING:
			moves = get_king_moves(piece, pos)
	
	return moves

func get_pawn_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	var direction = 1 if piece.color == "white" else -1
	
	# Move forward one square
	var forward = pos + Vector2i(direction, 0)
	if is_valid_square(forward) and board[forward.x][forward.y] == null:
		moves.append(forward)
		
		# Move forward two squares from starting position
		if (piece.color == "white" and pos.x == 6) or (piece.color == "black" and pos.x == 1):
			var double_forward = pos + Vector2i(direction * 2, 0)
			if is_valid_square(double_forward) and board[double_forward.x][double_forward.y] == null:
				moves.append(double_forward)
	
	# Capture diagonally
	for dy in [-1, 1]:
		var capture = pos + Vector2i(direction, dy)
		if is_valid_square(capture):
			var target = board[capture.x][capture.y]
			if target != null and target.color != piece.color:
				moves.append(capture)
	
	return moves

func get_rook_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	var directions = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	for dir in directions:
		for i in range(1, BOARD_SIZE):
			var new_pos = pos + dir * i
			if not is_valid_square(new_pos):
				break
			
			var target = board[new_pos.x][new_pos.y]
			if target == null:
				moves.append(new_pos)
			else:
				if target.color != piece.color:
					moves.append(new_pos)
				break
	
	return moves

func get_knight_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	var offsets = [
		Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, -2), Vector2i(-1, 2),
		Vector2i(1, -2), Vector2i(1, 2), Vector2i(2, -1), Vector2i(2, 1)
	]
	
	for offset in offsets:
		var new_pos = pos + offset
		if is_valid_square(new_pos):
			var target = board[new_pos.x][new_pos.y]
			if target == null or target.color != piece.color:
				moves.append(new_pos)
	
	return moves

func get_bishop_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	var directions = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	
	for dir in directions:
		for i in range(1, BOARD_SIZE):
			var new_pos = pos + dir * i
			if not is_valid_square(new_pos):
				break
			
			var target = board[new_pos.x][new_pos.y]
			if target == null:
				moves.append(new_pos)
			else:
				if target.color != piece.color:
					moves.append(new_pos)
				break
	
	return moves

func get_queen_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	# Queen combines rook and bishop moves
	return get_rook_moves(piece, pos) + get_bishop_moves(piece, pos)

func get_king_moves(piece: ChessPiece, pos: Vector2i) -> Array:
	var moves = []
	var offsets = [
		Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
		Vector2i(0, -1), Vector2i(0, 1),
		Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)
	]
	
	for offset in offsets:
		var new_pos = pos + offset
		if is_valid_square(new_pos):
			var target = board[new_pos.x][new_pos.y]
			if target == null or target.color != piece.color:
				moves.append(new_pos)
	
	return moves

func move_piece(from: Vector2i, to: Vector2i):
	var piece = board[from.x][from.y]
	var captured_piece = board[to.x][to.y]
	
	# Handle capture
	if captured_piece != null:
		Global.increment_captured()
		if captured_piece.type == PieceType.KING:
			# Checkmate!
			end_game(true)
	
	# Move piece
	board[to.x][to.y] = piece
	board[from.x][from.y] = null
	piece.position = to
	
	# Update game state
	Global.increment_moves()
	Global.add_score(10) # 10 points per move
	
	# Switch turns
	current_turn = "black" if current_turn == "white" else "white"
	Global.is_white_turn = (current_turn == "white")
	
	# Update UI
	update_ui()
	
	# Clear selection
	selected_piece = null
	selected_square = Vector2i(-1, -1)
	possible_moves = []

func update_ui():
	if score_label:
		score_label.text = "Score: %d" % Global.score
	if moves_label:
		moves_label.text = "Moves: %d" % Global.moves_count
	if turn_label:
		turn_label.text = "Turn: %s" % current_turn.capitalize()

func end_game(won: bool):
	Global.end_game(won)
	if won:
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")

func _draw():
	# Draw chess board
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var pos = Vector2(i * SQUARE_SIZE + 100, j * SQUARE_SIZE + 100)
			var color = Color.WHITE if (i + j) % 2 == 0 else Color("#4a5568")
			draw_rect(Rect2(pos, Vector2(SQUARE_SIZE, SQUARE_SIZE)), color)
			
			# Highlight selected square
			if selected_square == Vector2i(i, j):
				draw_rect(Rect2(pos, Vector2(SQUARE_SIZE, SQUARE_SIZE)), 
						  Color("#fbbf24", 0.5), false, 3)
			
			# Highlight possible moves
			if Vector2i(i, j) in possible_moves:
				var center = pos + Vector2(SQUARE_SIZE/2, SQUARE_SIZE/2)
				draw_circle(center, 10, Color("#10b981", 0.7))
	
	# Draw pieces
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE):
			var piece = board[i][j]
			if piece != null:
				draw_piece(piece, Vector2(i * SQUARE_SIZE + 100, j * SQUARE_SIZE + 100))

func draw_piece(piece: ChessPiece, pos: Vector2):
	var center = pos + Vector2(SQUARE_SIZE/2, SQUARE_SIZE/2)
	var color = Color.WHITE if piece.color == "white" else Color.BLACK
	
	# Draw piece based on type
	match piece.type:
		PieceType.PAWN:
			draw_circle(center, 25, color)
		PieceType.ROOK:
			draw_rect(Rect2(center - Vector2(20, 20), Vector2(40, 40)), color)
		PieceType.KNIGHT:
			# Draw triangle for knight
			var points = [
				center + Vector2(0, -25),
				center + Vector2(-20, 20),
				center + Vector2(20, 20)
			]
			draw_colored_polygon(points, color)
		PieceType.BISHOP:
			# Draw diamond for bishop
			var points = [
				center + Vector2(0, -25),
				center + Vector2(25, 0),
				center + Vector2(0, 25),
				center + Vector2(-25, 0)
			]
			draw_colored_polygon(points, color)
		PieceType.QUEEN:
			# Draw star for queen
			draw_star(center, 25, 5, color)
		PieceType.KING:
			# Draw hexagon for king
			draw_hexagon(center, 25, color)

func draw_star(center: Vector2, radius: float, points: int, color: Color):
	var angle = PI / points
	var vertices = []
	for i in range(points * 2):
		var r = radius if i % 2 == 0 else radius * 0.5
		var a = i * angle - PI/2
		vertices.append(center + Vector2(cos(a) * r, sin(a) * r))
	draw_colored_polygon(vertices, color)

func draw_hexagon(center: Vector2, radius: float, color: Color):
	var vertices = []
	for i in range(6):
		var angle = i * PI/3 - PI/2
		vertices.append(center + Vector2(cos(angle) * radius, sin(angle) * radius))
	draw_colored_polygon(vertices, color)

func _process(delta):
	queue_redraw()