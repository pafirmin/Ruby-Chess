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