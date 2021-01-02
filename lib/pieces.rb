class Game
	def initialize
		@board = Board.new
	end

	def new_game

	end
end

class Board
		attr_accessor :squares, :taken_pieces
		def initialize
			@squares = create_board
			@taken_pieces = []
    end

		def create_board
			arr = []
			(0..7).each do |x|
				(0..7).each do |y|
					arr << Square.new(x, y, self)
				end
			end
			arr
		end

		def find_square(x, y)
			@squares.find { |square| [square.x, square.y] == [x, y] }
		end
end

class Square
	attr_accessor :x, :y, :piece
	def initialize(x, y, board)
		@x = x
		@y = y
		@board = board
		@piece
	end

	def token
		@piece.token || '_'
	end

	def reachable?(piece_position, move)
		x = piece_position[0] + move[0]
		y = piece_position[1] + move[1]
		return [x, y] == square
	end

	def occupied?
		@piece != nil
	end

	def get_relative(x, y)
		@board.find_square(@x + x, @y + y)
	end

	def take(attacker)
		if occupied?
			@board.taken_pieces << @piece
		end

		@piece = attacker
	end
end

class Piece
	attr_accessor :current_square
	def initialize(colour)
		@colour = colour
	end

	def move(target)
		square.take(self)
	end
end

class Pawn < Piece
	def initialize(colour)
		super
		@moved = false
		@moveset = [[0, 1], [0, 2]]
		@token = colour == 'black' ? "\u2659" : "\u265f"
	end

	def move(target)
		@moved = true
		super
	end
end

class Rook < Piece
	def initialize(colour)
		super
		@moveset = [[0, 1], [1, 0], [0, -1], [-1, 0]]
		@token = colour == 'black' ? "\u2659" : "\u265f"
	end
	
	def valid_move?(target)
		for move in @moveset
			temp = target.get_relative(*move)
			until temp.nil?
				return true if temp.piece == self
				return false if temp.occupied?
				temp = temp.get_relative(*move)
			end
		end
		return false
	end
end

class Bishop < Piece
	def initialize(colour)
		super
		@moveset = [[1, 1,], [-1, -1], [-1, 1], [1, -1]]
		@token = colour == 'black' ? "\u2659" : "\u265f"
  end
end

class Knight < Piece
	def initialize(colour)
		super
		@moveset = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
		@token = colour == 'black' ? "\u2659" : "\u265f"
	end
	
	def valid_move?(start, target)
		moveset.some { |move| start.get_relative(*move) == square }
	end
end

board = Board.new

rook = Rook.new('black')

board.squares[0].piece = rook

puts rook.valid_move?(board.squares[7])