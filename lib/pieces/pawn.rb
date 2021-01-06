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
      @is_en_passant_capturable = (target.y - rank).abs == 2
      super
      promote! if rank == @promotion_row
    end
  end

  def self.all
    @@instances
  end

  private

  def promote!
    puts 'Promotion achieved! Choose a piece to replace your pawn: Q, N, R or B'
    choice = gets.chomp
    piece = get_promotion_piece(choice)
    @current_square.piece = piece
  end

  def get_promotion_piece(choice)
    case choice.upcase[0]
    when 'N'
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
      piece = square&.get_relative(0, 1)&.piece
    else
      piece = square&.get_relative(0, -1)&.piece
    end
    return false unless piece&.class == Pawn
    piece.is_en_passant_capturable
  end
end
