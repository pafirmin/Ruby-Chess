module Display
  def to_s
    rows = to_grid
    print_taken_pieces(:white)
    print_letter_row
    rows.each_with_index do |row, i|
      print [*(1..8)].reverse[i]
      row.each { |square| print square }
      print " #{[*(1..8)].reverse[i]}\n"
    end
    print_letter_row
    print_taken_pieces(:black)
  end

  def print_letter_row
    print ' '
    [*('A'..'H')].each { |pos| print " #{pos}" }
    print "\n"
  end

  def print_taken_pieces(colour)
    puts @taken_pieces.select { |piece| piece.colour == colour }.join
  end
end
