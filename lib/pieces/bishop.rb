class Bishop < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves
    @restricted_move = false
    @token = colour == :black ? "|\u265D" : "|\u2657"
  end
end