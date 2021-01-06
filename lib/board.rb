class Board
	include Display

  attr_reader :squares, :kings
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

  def castle_is_legal?(king, rook, moves)
    return false if king.has_moved? || rook&.has_moved?

    moves.none? do |move|
      square = king.current_square.get_relative(*move)
      square.occupied? or move_would_put_self_in_check?(king, square)
    end
  end

  def castle!(king, rook, side)
    y = king.rank
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
      Knight.new(colour, square)
    when 3, 6
      Bishop.new(colour, square)
    when 4
      Queen.new(colour, square)
    else
      @kings[colour] = King.new(colour, square)
      @kings[colour]
    end
  end

  def to_grid
    @squares.each_slice(8).to_a
  end
end