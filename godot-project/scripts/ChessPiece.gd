extends Resource
class_name ChessPiece

var type: Global.PieceType
var color: String
var position: Vector2i

func _init(piece_type: Global.PieceType, piece_color: String, piece_position: Vector2i):
	type = piece_type
	color = piece_color
	position = piece_position

func get_symbol() -> String:
	match type:
		Global.PieceType.PAWN:
			return "P"
		Global.PieceType.ROOK:
			return "R"
		Global.PieceType.KNIGHT:
			return "N"
		Global.PieceType.BISHOP:
			return "B"
		Global.PieceType.QUEEN:
			return "Q"
		Global.PieceType.KING:
			return "K"
		_:
			return "?"

func get_value() -> int:
	match type:
		Global.PieceType.PAWN:
			return 1
		Global.PieceType.ROOK:
			return 5
		Global.PieceType.KNIGHT:
			return 3
		Global.PieceType.BISHOP:
			return 3
		Global.PieceType.QUEEN:
			return 9
		Global.PieceType.KING:
			return 1000
		_:
			return 0