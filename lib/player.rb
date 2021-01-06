class Player
  attr_reader :colour, :name
  def initialize(name, colour)
    @name = name
    @colour = colour
  end

  def to_s
    @name.capitalize
  end
end