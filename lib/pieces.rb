class Game
  def initialize
    @board = Board.new
    @players = { white: nil, black: nil }
    @current_player = nil
    @checkmate = false
  end

  def run
    @board.deploy_pieces
    prompt_players
    @current_player = @players[:white]
    turn_loop
    game_over
  end

  private

  def prompt_players
    puts "White's name"
    @players[:white] = Player.new(gets.chomp, :white)
    puts "Black's name"
    @players[:black] = Player.new(gets.chomp, :black)
  end

  def turn_loop
		until @checkmate
			clear_en_passant
      puts "#{@current_player}'s turn"
      puts @board.to_s
      puts 'Choose piece to move'
      piece = choose_piece
      puts 'Choose target square'
      target = choose_square
      attempt_move(piece, target)
    end
  end

  def assess_board_for_check
    if @board.board_in_check?(@current_player.colour)
      if @board.checkmate?(@current_player.colour)
        puts 'CHECKMATE!'
        @checkmate = true
        switch_players
      else
        puts 'CHECK!'
      end
    end
  end

  def choose_piece
    loop do
      square = choose_square
      return square.piece if square.friendly?(@current_player.colour)

      puts 'Please select a valid piece.'
    end
  end

  def choose_square
    loop do
      choice = gets.chomp
      square = @board.find_square(alpha_to_num(choice[0]), choice[1])
      return square if square

      puts 'Invalid choice'
    end
  end

  def alpha_to_num(letter)
    letter.upcase.ord - 'A'.ord + 1
  end

  def attempt_move(piece, target)
    if @board.move_would_put_self_in_check?(piece, target)
      puts 'Cannot put yourself in check'
      nil
    elsif piece.can_move_to?(target)
      piece.move_to(target)
      switch_players
      assess_board_for_check
    else
      puts 'Invalid move'
    end
  end

  def switch_players
    @current_player = if @current_player.equal?(@players[:white])
                        @players[:black]
                      else
                        @players[:white]
                      end
	end
	
	def clear_en_passant
		Pawn.all.each do |pawn| 
			pawn.is_en_passant_capturable = false if pawn.colour == @current_player.colour
		end
	end

  def game_over
    @board.to_s
    puts "#{@current_player} wins!"
    exit
  end
end

class Player
  attr_reader :colour, :name
  def initialize(name, colour)
    @name = name
    @colour = colour
  end

  def to_s
    @name.capitalize
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
    grid[1].each { |square| square.piece = Pawn.new(:black, square) }
    grid[0].each { |square| square.piece = get_back_line_piece(:black, square) }
    grid[6].each { |square| square.piece = Pawn.new(:white, square) }
    grid[7].each { |square| square.piece = get_back_line_piece(:white, square) }
  end

  def find_square(x, y)
    @squares.find { |square| [square.x, square.y] == [x.to_i, y.to_i] }
  end

  def to_s
    rows = to_grid
    print_letter_row
    rows.each_with_index do |row, i|
      print [*(1..8)].reverse[i]
      row.each { |square| print square }
      print " #{[*(1..8)].reverse[i]}\n"
    end
    print_letter_row
  end

  def remove_piece(piece)
    @taken_pieces << piece
  end

  def board_in_check?(player_colour)
    @squares.each do |square|
      next unless square.hostile?(player_colour)
      return true if square.piece.valid_moves.any? do |target|
        target.friendly?(player_colour) and target.piece&.class == King
      end
    end
    false
  end

  def checkmate?(colour)
    @squares.select { |square| square.friendly?(colour) }
            .all? do |square|
      square.piece.valid_moves.all? do |target|
        move_would_put_self_in_check?(square.piece, target)
      end
    end
  end

  def move_would_put_self_in_check?(piece, target)
    self_check = false
    temp_piece = target.piece
    piece.current_square.piece = nil
    target.piece = piece
    self_check = true if board_in_check?(piece.colour)
    piece.current_square.piece = piece
    target.piece = temp_piece
    self_check
  end

  private

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

  def to_grid
    @squares.each_slice(8).to_a
  end

  def print_letter_row
    print ' '
    [*('A'..'H')].each { |pos| print " #{pos}" }
    print "\n"
  end
end

class Square
  attr_accessor :piece
  attr_reader :x, :y
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

  def hostile?(colour)
    occupied? and @piece.colour != colour
  end

  def get_relative(move_x, move_y)
    @board.find_square(@x + move_x, @y + move_y)
  end

  def take(attacker)
    @board.remove_piece(@piece) if occupied?
    @piece = attacker
	end
	
	def take_en_passant(attacker)
		@piece = attacker
		if attacker.colour == :black
			get_relative(0, 1).piece = nil
		else
			get_relative(0, -1).piece = nil
		end
	end
end

class Piece
	attr_reader :token, :colour, :current_square
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

  def valid_moves
    moves = []
    @moveset.each do |move|
      temp = @current_square.get_relative(*move)
      until temp.nil? or temp.friendly?(@colour)
        moves << temp
        break if temp.occupied?

        temp = temp.get_relative(*move)
      end
    end
    moves
  end
end

class King < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = true
    @token = colour == :black ? "|\u265A" : "|\u2654"
  end
end

class Queen < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = false
    @token = colour == :black ? "|\u265B" : "|\u2655"
  end
end

class Rook < Piece
  def initialize(colour, square)
    super
    @moveset = @straight_moves
    @restricted_move = false
    @token = colour == :black ? "|\u265C" : "|\u2656"
  end
end

class Bishop < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves
    @restricted_move = false
    @token = colour == :black ? "|\u265D" : "|\u2657"
  end
end

class Knight < Piece
  def initialize(colour, square)
    super
    @moveset = [[2, -1], [2, 1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
    @restricted_move = true
    @token = colour == :black ? "|\u265E" : "|\u2658"
	end
	
  def valid_moves
    moves = []
    @moveset.each do |move|
      square = @current_square.get_relative(*move)
      moves << square unless square.nil? or square.friendly?(@colour)
    end
    moves
  end
end

class Pawn < Piece
	@@instances = []
	attr_accessor :is_en_passant_capturable
  def initialize(colour, square)
    super
    @moveset = colour == :black ? [[0, -1], [0, -2]] : [[0, 1], [0, 2]]
		@take_moves = colour == :black ? [[-1, -1], [1, -1]] : [[1, 1], [-1, 1]]
		@en_passant_positions = [[-1, 0], [1, 0]]
		@is_en_passant_capturable = false
		@token = colour == :black ? "|\u265F" : "|\u2659"
		@@instances << self
  end

  def valid_moves
    moves = []
    @moveset.each do |move|
      square = @current_square.get_relative(*move)
      moves << square unless square.occupied?
    end
    @take_moves.each do |move|
      square = @current_square.get_relative(*move)
      moves << square if square&.hostile?(@colour) or can_move_en_passant(square)
		end
    moves
	end

	
	def move_to(target)
		if can_move_en_passant(target)
			target.take_en_passant(self)
			@current_square.piece = nil
			@current_square = target
		else
			@is_en_passant_capturable = (target.y - @current_square.y).abs == 2
			super
		end
    @moveset = [@moveset[0]]
	end
	
	def self.all
		@@instances
	end

	private

	def can_move_en_passant(square)
		if @colour == :black
			return square&.get_relative(0, 1)&.piece&.is_en_passant_capturable
		else
			return square&.get_relative(0, -1)&.piece&.is_en_passant_capturable
		end
	end
end

game = Game.new

game.run
