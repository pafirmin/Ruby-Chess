class Piece
  attr_reader :token, :colour, :current_square
  def initialize(colour, square)
    @straight_moves = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    @diagonal_moves = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    @colour = colour
    @current_square = square
	end
	
	def to_s
		@token
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