class Piece
  attr_reader :colour, :current_square
  def initialize(colour, square)
    @straight_moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    @diagonal_moves = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    @colour = colour
    @current_square = square
    @selected = false
  end

  def to_s
    @selected ? token.green : token
  end

  def toggle_selected
    @selected = !@selected
  end

  def token
    @colour == :black ? @token.light_black.to_s : @token.white.to_s
  end

  def move_to(target)
    @current_square.piece = nil
    target.take(self)
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

  def rank
    @current_square.y
  end

  private

  def valid_moves_restricted
    moves = []
    @moveset.each do |move|
      square = @current_square.get_relative(*move)
      moves << square unless !square || square&.friendly?(@colour)
    end
    moves
  end
end
