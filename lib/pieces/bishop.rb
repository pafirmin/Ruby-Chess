class Bishop < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves
    @restricted_move = false
    @token = "\u265D"
  end
end
