extends Node

signal score_changed(new_score: int)
signal game_state_changed(new_state: String)

enum GameState { MENU, PLAYING, VICTORY, DEFEAT }

var score: int = 0
var high_score: int = 0
var player_name: String = "Player"
var game_state: GameState = GameState.MENU
var moves_count: int = 0
var pieces_captured: int = 0
var game_time: float = 0.0
var is_white_turn: bool = true

# Game statistics
var games_played: int = 0
var games_won: int = 0
var games_lost: int = 0

func _ready():
	load_game_data()

func add_score(points: int):
	score += points
	score_changed.emit(score)
	save_game_data()

func reset_score():
	score = 0
	moves_count = 0
	pieces_captured = 0
	game_time = 0.0
	score_changed.emit(score)

func set_game_state(state: GameState):
	game_state = state
	game_state_changed.emit(GameState.keys()[state].to_lower())

func increment_moves():
	moves_count += 1

func increment_captured():
	pieces_captured += 1
	add_score(50) # 50 points per captured piece

func save_game_data():
	# Save to localStorage using JavaScript interface
	if OS.get_name() == "HTML5":
		JavaScriptBridge.eval("""
		window.parent.postMessage({
			type: 'applaa-game-save-score',
			gameId: 'chess2',
			playerName: arguments[0],
			score: arguments[1]
		}, '*');
		""", [player_name, score])
		
		# Save custom game data
		JavaScriptBridge.eval("""
		window.parent.postMessage({
			type: 'applaa-game-save-data',
			gameId: 'chess2',
			data: {
				gamesPlayed: arguments[0],
				gamesWon: arguments[1],
				gamesLost: arguments[2],
				highScore: arguments[3]
			}
		}, '*');
		""", [games_played, games_won, games_lost, high_score])

func load_game_data():
	if OS.get_name() == "HTML5":
		# Request game data from localStorage
		JavaScriptBridge.eval("""
		window.parent.postMessage({
			type: 'applaa-game-load-data',
			gameId: 'chess2'
		}, '*');
		
		// Set up listener for response
		window.addEventListener('message', function(event) {
			if (event.data.type === 'applaa-game-data-loaded') {
				const data = event.data.data;
				if (data) {
					// Update high score display
					const highScoreElements = document.querySelectorAll('.high-score-display');
					highScoreElements.forEach(el => {
						el.textContent = 'High Score: ' + (data.highScore || 0);
						el.style.display = 'block';
					});
					
					// Pre-fill player name
					const nameInputs = document.querySelectorAll('.player-name-input');
					nameInputs.forEach(el => {
						if (data.lastPlayerName) el.value = data.lastPlayerName;
					});
				}
			}
		});
		""")

func end_game(won: bool):
	games_played += 1
	if won:
		games_won += 1
		add_score(500) # 500 points for winning
	else:
		games_lost += 1
	
	if score > high_score:
		high_score = score
	
	save_game_data()