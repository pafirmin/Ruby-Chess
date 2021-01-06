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
    @board.remove_piece(self) if occupied?
    @piece = attacker
  end

  def take_en_passant(attacker)
    @piece = attacker
    if attacker.colour == :black
      square = get_relative(0, 1)
      @board.remove_piece(square)
    else
      square = get_relative(0, -1)
      @board.remove_piece(square)
    end
  end
end
