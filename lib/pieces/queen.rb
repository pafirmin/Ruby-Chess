class Queen < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = false
    @token = "\u265B"
  end
end
