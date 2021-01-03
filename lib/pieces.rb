class Game
  def initialize
    @board = Board.new
  end

	def new_game
		@board.print_board
		chosen_piece = gets.chomp
		piece = @board.find_square(chosen_piece[0].to_i, chosen_piece[1].to_i).piece

		target_coords = gets.chomp
		target = @board.find_square(target_coords[0].to_i, target_coords[1].to_i)

		piece.move(target) if piece.valid_move?(target)

		@board.print_board

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
		arr[0].piece = Rook.new('black', arr[0])
    arr
	end


	def find_square(x, y)
    @squares.find { |square| [square.x, square.y] == [x, y] }
	end
	
	def print_board
		rows = @squares.map(&:print).each_slice(8).to_a
		rows.each { |row| puts row.join('') }
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

  def print
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
  attr_reader :token
  def initialize(colour, current_square)
		@colour = colour
		@current_square = current_square
  end

  def move(target)
		target.take(self)
		@current_square.piece = nil
		@current_square = target
  end

  def valid_move?(target)
    @restricted_move ? check_restricted_move(target) : check_unrestricted_move(target)
  end

  private

  def check_unrestricted_move(target)
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

  def check_restricted_move(target)
    moveset.some { |move| target.get_relative(*move).piece == self }
  end
end

class King < Piece

end

class Queen < Piece

end

class Pawn < Piece
  def initialize(colour)
    super
    @moveset = [[0, 1], [0, 2]]
    @token = colour == 'black' ? "\u2659" : "\u265f"
    @restricted_move = true
  end

  def move(target)
    @moveset = [[0, 1]]
    super
  end
end

class Rook < Piece
  def initialize(colour, current_square)
    super
    @moveset = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    @token = colour == 'black' ? "|\u2659" : "|\u265f"
    @restricted_move = false
  end
end

class Bishop < Piece
  def initialize(colour)
    super
    @moveset = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    @token = colour == 'black' ? "\u2659" : "\u265f"
    @restricted_move = false
  end
end

class Knight < Piece
  def initialize(colour)
    super
    @moveset = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
    @token = colour == 'black' ? "\u2659" : "\u265f"
    @restricted_move = true
  end
end

game = Game.new

game.new_game