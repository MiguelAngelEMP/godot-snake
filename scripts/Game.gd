extends Node

const SNAKE = 0
const EGGS = 1
const TILE_SIZE = 16

var game_started:bool = false
var score:int = 0
var max_score:int = 0

var egg_pos:Vector2
var egg_eaten:bool = false

var snake_body = [Vector2(10,7), Vector2(9,7), Vector2(8,7)]
var snake_direction:Vector2 = Vector2(1,0)
var direction_taken = false


func _ready():
	randomize()


func _input(_event):
	if Input.is_action_pressed("ui_up") and not direction_taken:
		if snake_direction != Vector2(0,1):
			direction_taken = true
			snake_direction = Vector2(0,-1)
	if Input.is_action_pressed("ui_down") and not direction_taken:
		if snake_direction != Vector2(0,-1):
			direction_taken = true
			snake_direction = Vector2(0,1)
	if Input.is_action_pressed("ui_left") and not direction_taken:
		if snake_direction != Vector2(1,0):
			direction_taken = true
			snake_direction = Vector2(-1,0)
	if Input.is_action_pressed("ui_right") and not direction_taken:
		if snake_direction != Vector2(-1,0):
			direction_taken = true
			snake_direction = Vector2(1,0)


func _process(_delta):
	check_start()


func place_egg():
	var x = randi() % 20
	var y = randi() % 15
	while Vector2(x, y) in snake_body:
		x = randi() % 20
		y = randi() % 15
	return Vector2(x, y)


func draw_egg():
	$SnakeGrid.set_cell(egg_pos.x, egg_pos.y, EGGS)


func check_egg():
	# If the egg is in the same position than the head of the snake
	if egg_pos == snake_body[0]:
		egg_pos = place_egg()
		egg_eaten = true
		score += 1


func draw_snake():
	for part_index in snake_body.size():
		var part = snake_body[part_index]
		
		# snake head
		if part_index == 0:
			var head_dir = _relation_snake_body(snake_body[part_index], snake_body[part_index+1])
			match head_dir:
				'left':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, false, Vector2(2,0))
				'right':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, false, false, Vector2(2,0))
				'up':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, true, Vector2(2,0))
				'down':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, true, true, Vector2(2,0))
		# snake tail
		elif part_index == snake_body.size() -1:
			var tail_dir = _relation_snake_body(snake_body[part_index], snake_body[part_index-1])
			match tail_dir:
				'right':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, false, Vector2(0,0))
				'left':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, false, false, Vector2(0,0))
				'down':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, true, Vector2(0,0))
				'up':
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, true, true, Vector2(0,0))
		# Rest of the body
		else:
			var previous_part = snake_body[part_index+1] - part
			var next_part = snake_body[part_index-1] - part
			
			# Horizontal and vertical body parts
			if previous_part.x == next_part.x:
				if previous_part.y < next_part.y:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, true, Vector2(1,0))
				else:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, true, true, Vector2(1,0))
			elif previous_part.y == next_part.y:
				if previous_part.x < next_part.x:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, false, Vector2(1,0))
				else:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, false, false, Vector2(1,0))
			
			# Corners of snake
			else:
				if previous_part.x == -1 and next_part.y == -1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, true, true, Vector2(3,0))
				elif next_part.x == -1 and previous_part.y == -1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, true, false, Vector2(3,0))
				
				elif previous_part.x == 1 and next_part.y == 1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, true, Vector2(3,0))
				elif next_part.x == 1 and previous_part.y == 1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, false, false, Vector2(3,0))
				
				elif previous_part.x == -1 and next_part.y == 1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, false, true, Vector2(3,0))
				elif next_part.x == -1 and previous_part.y == 1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, true, false, false, Vector2(3,0))
				
				if previous_part.x == 1 and next_part.y == -1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, true, true, Vector2(3,0))
				elif next_part.x == 1 and previous_part.y == -1:
					$SnakeGrid.set_cell(part.x, part.y, SNAKE, false, true, false, Vector2(3,0))


func _relation_snake_body(first_part:Vector2, second_part:Vector2):
	var relation = second_part - first_part
	match relation:
		Vector2(-1,0):
			return 'left'
		Vector2(1,0):
			return 'right'
		Vector2(0,-1):
			return 'up'
		Vector2(0,1):
			return 'down'


func _delete_tiles(id:int):
	var cells = $SnakeGrid.get_used_cells_by_id(id)
	
	for cell in cells:
		$SnakeGrid.set_cell(cell.x, cell.y, $SnakeGrid.INVALID_CELL)


func move_snake():
	if egg_eaten:
		_delete_tiles(SNAKE)
		# snake_copy is a copy of the entire snake
		var snake_copy = snake_body.slice(0, snake_body.size() - 1)
		var snake_new_head = snake_copy[0] + snake_direction
		snake_copy.insert(0, snake_new_head)
		snake_body = snake_copy
		egg_eaten = false
	else:
		_delete_tiles(SNAKE)
		# snake_copy is a copy of the snake but without the tail
		var snake_copy = snake_body.slice(0, snake_body.size() - 2) 
		var snake_new_head = snake_copy[0] + snake_direction
		snake_copy.insert(0, snake_new_head)
		snake_body = snake_copy


func check_game_over():
	var snake_head = snake_body[0]
	
	# Snake out of bounds
	if snake_head.x < 0 or snake_head.x > 19 or snake_head.y < 0 or snake_head.y > 14:
		game_over()
	# Snake eats itself
	else:
		for block in snake_body.slice(1, snake_body.size() -1):
			if block == snake_head:
				game_over()


func game_over():
	set_max_score(score)
	$GUI.update_score(score)
	
	$GUI.toggle_start_panel()
	game_started = false


func set_max_score(new_score):
	if new_score > max_score:
		max_score = new_score
		$GUI.update_max_score(new_score)


func check_start():
	if not game_started and Input.is_action_just_pressed("ui_select"):
		game_started = true
		$GUI.toggle_start_panel()
		start_game()


func start_game():
	clear_game()
	snake_body = [Vector2(10,7), Vector2(9,7), Vector2(8,7)]
	snake_direction = Vector2(1,0)
	egg_pos = place_egg()
	score = 0
	
	draw_egg()
	draw_snake()


func clear_game():
	_delete_tiles(SNAKE)
	_delete_tiles(EGGS)


func _on_SnakeTick_timeout():
	if game_started:
		move_snake()
		direction_taken = false
		check_egg()
		draw_egg()
		draw_snake()
		check_game_over()
		$GUI.update_score(score)
