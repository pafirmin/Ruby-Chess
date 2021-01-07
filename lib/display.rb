module Display
  def to_s
    rows = @rotated ? to_grid_rotated : to_grid
    print_taken_pieces(:white)
    print_file_markers
    rows.each_with_index do |row, i|
      print rank_markers[i]
      row.each { |square| print square }
      print " #{rank_markers[i]}\n"
    end
    print_file_markers
    print_taken_pieces(:black)
  end

  def print_file_markers
    letters = [*('A'..'H')]
    letters.reverse! if @rotated
    print ' '
    letters.each { |letter| print " #{letter}" }
    print "\n"
  end

  def rank_markers
    numbers = [*(1..8)]
    numbers.reverse! unless @rotated
    numbers
  end

  def print_taken_pieces(colour)
    puts @taken_pieces.select { |piece| piece.colour == colour }.join
  end
end
