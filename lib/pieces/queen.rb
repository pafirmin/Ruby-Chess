class Queen < Piece
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @restricted_move = false
    @token = colour == :black ? "|\u265B" : "|\u2655"
  end
end
