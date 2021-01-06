class King < Piece
  attr_reader :castle_moves
  def initialize(colour, square)
    super
    @moveset = @diagonal_moves + @straight_moves
    @castle_moves = { queenside: [[-1, 0], [-2, 0]], kingside: [[1, 0], [2, 0]] }
    @restricted_move = true
    @token = colour == :black ? "|\u265A" : "|\u2654"
    @moved = false
  end

  def move_to(target)
    @moved = true
    super
  end

  def valid_moves
    valid_moves_restricted
  end

  def has_moved?
    @moved
  end
end