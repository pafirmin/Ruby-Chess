class Rook < Piece
  def initialize(colour, square)
    super
    @moveset = @straight_moves
    @restricted_move = false
    @token = "\u265C"
    @moved = false
  end

  def move_to(target)
    @moved = true
    super
  end

  def has_moved?
    @moved
  end
end
