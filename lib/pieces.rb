class Game
  def initialize
    @board = Board.new
    @players = {white: nil, black: nil}
    @current_player = nil
  end

  def new_game
    @board.deploy_pieces
		prompt_players
		@current_player = @players[:white]
    turn_loop
  end

  def prompt_players
    puts "White's name"
    @players[:white] = Player.new(gets.chomp, 'white')
    puts "Black's name"
    @players[:black] = Player.new(gets.chomp, 'black')
  end

  def turn_loop
    loop do
			@board.print_board
			puts 'Choose piece to move'
			piece = choose_piece
			puts 'Choose target square'
      target = choose_square
			attempt_move(piece, target)
			puts @board.board_in_check?(@current_player.colour)
    end
	end
	
	def choose_piece
		square = choose_square
		if !square.friendly?(@current_player.colour)
			puts 'Please select a valid piece.'
			choose_piece
		end
		square.piece
	end

  def choose_square
    choice = gets.chomp
		square = @board.find_square(choice[0], choice[1])
		if square.nil? 
			puts 'Invalid choice'
			choose_square
		end
		square
	end
	
  def attempt_move(piece, target)
    if piece.can_move_to?(target)
			piece.move_to(target)
			switch_players
    else
      puts 'Invalid move'
    end
	end
	
	def switch_players
		if @current_player.equal?(@players[:white])
			@current_player = @players[:black]
		else
			@current_player = @players[:white]
		end
	end
end

class Player
	attr_reader :colour, :name
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
    [*(1..8)].reverse.each do |y|
      (1..8).each do |x|
        arr << Square.new(x, y, self)
      end
    end
    arr
  end

  def deploy_pieces
    grid = to_grid
    grid[1].each { |square| square.piece = Pawn.new('black', square) }
    grid[0].each { |square| square.piece = get_back_line_piece('black', square) }
    grid[6].each { |square| square.piece = Pawn.new('white', square) }
    grid[7].each { |square| square.piece = get_back_line_piece('white', square) }
  end

  def get_back_line_piece(colour, square)
    case square.x
    when 1, 8
      Rook.new(colour, square)
    when 2, 7
      Knight.new(colour, square)
    when 3, 6
      Bishop.new(colour, square)
    when 4
      Queen.new(colour, square)
    else
      King.new(colour, square)
    end
  end

  def find_square(x, y)
    @squares.find { |square| [square.x, square.y] == [x.to_i, y.to_i] }
  end

  def print_board
    rows = @squares.map(&:to_s).each_slice(8).to_a
    rows.each { |row| puts row.join('') }
  end

  def to_grid
    @squares.each_slice(8).to_a
  end

  def remove_piece(piece)
    @taken_pieces << piece
	end
	
	def board_in_check?(player_colour)
		@squares.each do |square|
			if square.occupied? && !square.friendly?(player_colour)
				return true if square.piece.valid_moves.any? { |target| target.friendly?(player_colour) && target.piece&.class == King  }
			end
		end
		false
	end
end

class Square
  attr_accessor :x, :y, :piece
  def initialize(x, y, board)
    @x = x
    @y = y
    @board = board
    @piece = nil
  end

  def to_s
    occupied? ? @piece.token : '|_'
  end

  def occupied?
    @piece != nil
  end

  def friendly?(colour)
    @piece&.colour == colour
  end

  def get_relative(move_x, move_y)
    @board.find_square(@x + move_x, @y + move_y)
  end

  def take(attacker)
    @board.remove_piece(@piece) if occupied?
    @piece = attacker
  end
end

class Piece
  attr_reader :token, :colour
  def initialize(colour, square)
    @straight_moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    @diagonal_moves = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    @colour = colour
    @current_square = square
  end

  def move_to(target)
    target.take(self)
    @current_square.piece = nil
    @current_square = target
  end

  def can_move_to?(target)
    valid_moves.include?(target)
	end

	private
	
	def valid_moves_unrestricted
		moves = []
    @moveset.each do |move|
      temp = @current_square.get_relative(*move)
      until temp.nil? || temp.friendly?(@colour)
        moves << temp
        break if temp.occupied?
        temp = temp.get_relative(*move)
			end
    end	
		moves
	end

	def valid_moves_restricted
		moves = []
		@moveset.each do |move| 
			temp = @current_square.get_relative(*move) 
			moves << temp if !temp.nil? && !temp.friendly?(@colour)
		end
		moves
	end
end

class King < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = true
    @token = colour == 'black' ? "|\u265A" : "|\u2654"
	end
	
	def valid_moves
		valid_moves_restricted
	end
end

class Queen < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = false
    @token = colour == 'black' ? "|\u265B" : "|\u2655"
	end
	
	def valid_moves
		valid_moves_unrestricted
	end
end

class Rook < Piece
  def initialize(colour, square)
    super
    @moveset = @straight_moves
    @restricted_move = false
    @token = colour == 'black' ? "|\u265C" : "|\u2656"
	end
	
	def valid_moves
		valid_moves_unrestricted
	end
end

class Bishop < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves
    @restricted_move = false
    @token = colour == 'black' ? "|\u265D" : "|\u2657"
	end
	
	def valid_moves
		valid_moves_unrestricted
	end
end

class Knight < Piece
  def initialize(colour, square)
    super
    @moveset = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
    @restricted_move = true
    @token = colour == 'black' ? "|\u265E" : "|\u2658"
	end
	
	def valid_moves
		valid_moves_restricted
	end
end

class Pawn < Piece
  def initialize(colour, square)
    super
    @moveset = colour == 'black' ? [[0, -1], [0, -2]] : [[0, 1], [0, 2]]
    @take_moves = colour == 'black' ? [[-1, -1], [1, -1]] : [[1, 1], [-1, 1]]
    @restricted_move = true
    @token = colour == 'black' ? "|\u265F" : "|\u2659"
	end
	
	def valid_moves
		valid_moves_restricted
	end

  def can_move_to?(target)
    if target.occupied? && !target.friendly?(@colour)
      @take_moves.any? { |move| @current_square.get_relative(*move) == target }
    else
      super
    end
	end
	
  def move(target)
    @moveset = [@moveset[0]]
    super
  end
end

game = Game.new

game.new_game