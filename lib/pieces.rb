class Game
  def initialize
		@board = Board.new
		@players = []
  end

	def new_game
		@board.deploy_pieces
		@board.print_board
	end
	
	def get_players
		player_one_name = gets.chomp
		players << Player.new(player_one_name, 'white')
		player_two_name = gets.chomp
		players << Player.new(player_two_name, 'black')
	end
end

class Player
	def initialize(name, colour)
		@name = name
		@colour = colour
	end
end

class Board
	attr_reader :squares
	attr_writer :taken_pieces
  def initialize
    @squares = create_board
    @taken_pieces = []
  end

  def create_board
    arr = []
		(1..8).each do |y|
      (1..8).each do |x|
        arr << Square.new(x, y, self)
      end
		end
    arr
	end

	def deploy_pieces
		grid = to_grid
		black_pawn_row, white_pawn_row = grid[1], grid[6]
		black_back_line, white_back_line = grid[0], grid[7]

		black_pawn_row.each { |square| square.piece = Pawn.new('black', square) }
		white_pawn_row.each { |square| square.piece = Pawn.new('white', square) }
		black_back_line.each { |square| square.piece = get_back_line_piece('black', square) }
		white_back_line.each { |square| square.piece = get_back_line_piece('white', square) }
	end

	def get_back_line_piece(colour, square)
		case square.x
		when 1, 8
			return Rook.new(colour, square)
		when 2, 7
			return Knight.new(colour, square)
		when 3, 6
			return Bishop.new(colour, square)
		when 4
			return Queen.new(colour, square)
		else
			return King.new(colour, square)
		end
	end

	def find_square(x, y)
    @squares.find { |square| [square.x, square.y] == [x, y] }
	end
	
	def print_board
		rows = @squares.map(&:to_s).each_slice(8).to_a
		rows.each { |row| puts row.join('') }
	end

	def to_grid
		@squares.each_slice(8).to_a
	end
end

class Square
  attr_accessor :x, :y, :piece
  def initialize(x, y, board, piece = nil)
    @x = x
    @y = y
    @board = board
    @piece = piece
  end

  def to_s
    occupied? ? @piece.token : '|_'
  end

  def occupied?
    @piece != nil
  end

  def get_relative(move_x, move_y)
    @board.find_square(@x + move_x, @y + move_y)
  end

  def take(attacker)
    @board.taken_pieces << @piece if occupied?

    @piece = attacker
  end
end

class Piece
	attr_reader :token, :colour
	@@straight_moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
	@@diagonal_moves = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
  def initialize(colour, square)
		@colour = colour
		@current_square = square
  end

  def move(target)
		target.take(self)
		@current_square.piece = nil
		@current_square = target
  end

  def valid_move?(target)
		if @restricted_move
			validate_unrestricted_move
		else
			validate_unrestricted_move
		end
  end

  private

  def validate_unrestricted_move(target)
    @moveset.each do |move|
      temp = target.get_relative(*move)
      until temp.nil?
        return true if temp.piece == self
        return false if temp.occupied?
        temp = temp.get_relative(*move)
      end
    end
    false
  end

  def validate_restricted_move(target)
    moveset.any? { |move| target.get_relative(*move).piece == self }
  end
end

class King < Piece
	def initialize(colour, square)
		super
		@moveset = @@diagonal_moves + @@straight_moves
		@restricted_move = true
		@token = colour == 'black' ? "|\u265A" : "|\u2654"
	end

	def in_check?
		@@diagonal_moves.each do |move|

		end
	end
end

class Queen < Piece
	def initialize(colour, square)
		super
		@moveset = @@diagonal_moves + @@straight_moves
		@restricted_move = false
		@token = colour == 'black' ? "|\u265B" : "|\u2655"
	end
end

class Pawn < Piece
  def initialize(colour, square)
    super
    @moveset = colour == 'black' ? [[0, -1], [0, -2]] : [[0, 1], [0, 2]]
    @take_moves = colour == 'black' ? [[-1, -1], [+1, -1]] : [[1, 1], [-1, 1]]
    @restricted_move = true
    @token = colour == 'black' ? "|\u265F" : "|\u2659"
	end
	
	def valid_move?(target)
		if target.occupied? && target.piece.colour != @colour
			take_moves.any? { |move| @current_square.get_relative(*move).piece == target }
		else
			super
		end
	end

  def move(target)
    @moveset = [@moveset[0]]
    super
  end
end

class Rook < Piece
  def initialize(colour, square)
    super
    @moveset = @@straight_moves
    @restricted_move = false
    @token = colour == 'black' ? "|\u265C" : "|\u2656"
  end
end

class Bishop < Piece
  def initialize(colour, square)
    super
    @moveset = @@diagonal_moves
    @restricted_move = false
    @token = colour == 'black' ? "|\u265D" : "|\u2657"
  end
end

class Knight < Piece
  def initialize(colour, square)
    super
    @moveset = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
    @restricted_move = true
    @token = colour == 'black' ? "|\u265E" : "|\u2658"
  end
end

game = Game.new

game.new_game