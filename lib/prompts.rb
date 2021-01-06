module Prompts
  def welcome_message
    <<-HEREDOC
    Welcome to Ruby Chess, written by Paul Firmin. Thanks for playing.
      
    System requirements:
      Magnifying glass.

    Instructions:
      To move a piece, first select it by entering its coordinates (e.g. 'B1').
      Then, select a valid square to move to (e.g. 'C3'). To castle, enter 'O-O' 
      for a kingside manoeuvre or 'O-O-O' for queenside. Inputs are not 
      case-sensitive. Depending on your console display, colours may appear
      to be reversed. Well, they're not. Trust me.

      To save or load a game, simply enter 'save' or 'load'.
      
      To get started, please enter your names...\n
    HEREDOC
  end

  def show_help
    <<-HEREDOC
    Movement:
      Select piece: Enter piece coordinate (eg. 'B1').
      Move piece: Enter target square coordinate (e.g. 'C3')
      Castling: 'O-O' for kingside; 'O-O-O' for queenside.
    Save or load a game: 
      Enter 'save' or 'load' \n
    HEREDOC
  end

  def prompt_players
    puts "White's name"
    @players[:white] = Player.new(gets.chomp, :white)
    puts "Black's name"
    @players[:black] = Player.new(gets.chomp, :black)
  end

  def prompt_for_piece
    puts 'Choose piece to move'
    piece = choose_piece
  end

  def prompt_for_target
    puts 'Choose target square'
    target = choose_square
  end
end
