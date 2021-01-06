# frozen_string_literal: true

class Game
  def initialize
    @board = Board.new
    @players = { white: nil, black: nil }
    @current_player = nil
    @checkmate = false
  end

  def run
    prompt_players
    @board.deploy_pieces
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
    return unless @board.board_in_check?(@current_player.colour)
    if @board.checkmate?(@current_player.colour)
      puts 'CHECKMATE!'
			@checkmate = true
		  switch_players
    else
      puts 'CHECK!'
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
      if choice.upcase!.start_with?('O-O')
        castle_move(choice)
        break
      else
        square = @board.find_square(alpha_to_num(choice[0]), choice[1])
        return square if square
      end

      puts 'Invalid choice'
    end
  end

  def castle_move(move)
    king = @board.kings[@current_player.colour]
    if move == 'O-O'
      side = :kingside
      rook = @board.find_square(8, king.current_square.y).piece
    elsif move == 'O-O-O'
      side = :queenside
      rook = @board.find_square(1, king.current_square.y).piece
    end
    moves = king.castle_moves[side]
		if @board.can_castle?(king, rook, moves)
			@board.castle!(king, rook, side) 
			switch_players
			turn_loop
		else
			puts 'Cannot castle right now'
			turn_loop
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
  attr_reader :squares, :kings
  attr_writer :taken_pieces
  def initialize
    @squares = create_board
    @taken_pieces = []
    @kings = { black: nil, white: nil }
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
        target.friendly?(player_colour) && (target.piece == @kings[player_colour])
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

  def can_castle?(king, rook, moves)
    return false if king.has_moved? || rook&.has_moved?

    moves.none? do |move|
      square = king.current_square.get_relative(*move)
      square.occupied? or move_would_put_self_in_check?(king, square)
    end
  end

  def castle!(king, rook, side)
    y = king.current_square.y
    if side == :kingside
      new_king_position = find_square(7, y)
      new_rook_position = find_square(6, y)
    elsif side == :queenside
      new_king_position = find_square(3, y)
      new_rook_position = find_square(4, y)
    end
    king.move_to(new_king_position)
    rook.move_to(new_rook_position)
  end

  private

  def get_back_line_piece(colour, square)
    case square.x
    when 1, 8
      Rook.new(colour, square)
    when 2, 7
      # Knight.new(colour, square)
    when 3, 6
      # Bishop.new(colour, square)
    when 4
      # Queen.new(colour, square)
    else
      @kings[colour] = King.new(colour, square)
      @kings[colour]
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
      until temp.nil? || temp.friendly?(@colour)
        moves << temp
        break if temp.occupied?

        temp = temp.get_relative(*move)
      end
    end
    moves
  end

  private

  def valid_moves_restricted
    moves = []
    @moveset.each do |move|
      square = @current_square.get_relative(*move)
      moves << square unless square.nil? || square.friendly?(@colour)
    end
    moves
  end
end

class King < Piece
  attr_reader :castle_moves
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @castle_moves = { queenside: [[-1, 0], [-2, 0]], kingside: [[1, 0], [2, 0]] }
    @restricted_move = true
    @token = colour == :black ? "|\u265A" : "|\u2654"
    @moved = false
  end

  def move_to(target)
    @moved = true
    super
  end

  def valid_moves
    valid_moves_restricted
  end

  def has_moved?
    @moved
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
    @moved = false
  end

  def move_to(target)
    @moved = true
    super
  end

  def has_moved?
    @moved
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
    valid_moves_restricted
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
    @promotion_row = colour == :black ? 1 : 8
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
      moves << square if square&.hostile?(@colour) || can_move_en_passant(square)
    end
    moves
  end

  def move_to(target)
    @moveset = [@moveset[0]]
    if can_move_en_passant(target)
      target.take_en_passant(self)
      @current_square.piece = nil
      @current_square = target
    else
      @is_en_passant_capturable = (target.y - @current_square.y).abs == 2
      super
      promote! if current_square.y == @promotion_row
    end
  end

  def self.all
    @@instances
  end

  private

  def promote!
    puts 'Promotion achieved! Choose a piece to replace your pawn'
    choice = gets.chomp
    piece = get_promotion_piece(choice)
    @current_square.piece = piece
  end

  def get_promotion_piece(choice)
    case choice.upcase[0]
    when 'K'
      Knight.new(@colour, @current_square)
    when 'B'
      Bishop.new(@colour, @current_square)
    when 'R'
      Rook.new(@colour, @current_square)
    else
      Queen.new(@colour, @current_square)
    end
  end

  def can_move_en_passant(square)
    if @colour == :black
      square&.get_relative(0, 1)&.piece&.is_en_passant_capturable
    else
      square&.get_relative(0, -1)&.piece&.is_en_passant_capturable
    end
  rescue StandardError
    false
  end
end

game = Game.new

game.run
