class Game
  include SaveManager
  include Prompts

  def initialize
    @board = Board.new
    @players = { white: nil, black: nil }
    @current_player = nil
    @checkmate = false
  end

  def run
    puts welcome_message
    prompt_players
    @board.set_board
    @current_player = @players[:white]
    turn_loop
    game_over
  end

  def turn_loop
    until @checkmate
      clear_en_passant
      puts @board.to_s
      puts "#{@current_player}'s turn"
      piece = prompt_for_piece
      puts @board.to_s
      target = prompt_for_target
      attempt_move(piece, target)
    end
  end

  private

  def assess_board_for_check
    return unless @board.in_check?(@current_player.colour)

    if @board.checkmate?(@current_player.colour)
      puts 'CHECKMATE!'
      @checkmate = true
      switch_players
    else
      puts 'CHECK!'
    end
  end

  def choose_piece
    loop do
      square = user_input
      if !square.friendly?(@current_player.colour)
        puts 'Please select a valid piece.'
      elsif square.piece.valid_moves.empty?
        puts 'Piece has no legal moves.'
      else
        piece = square.piece
        piece.toggle_selected
        return piece
      end
    end
  end

  def user_input
    loop do
      choice = gets.chomp
      if choice.downcase == 'save'
        save_game(self)
        redo
      elsif choice.downcase == 'load'
        load_game
        redo
      elsif choice.downcase == 'help'
        puts show_help
        redo
      elsif choice.downcase == 'flip'
        @board.rotate_board
        redo
      elsif choice.upcase!.start_with?('O-O')
        castle_move(choice)
        break
      else
        square = @board.find_square(alpha_to_num(choice[0]), choice[1])
        return square if square
      end

      puts 'Invalid choice'
    end
  end

  def castle_move(move)
    king = @board.kings[@current_player.colour]
    if move == 'O-O'
      side = :kingside
      rook = @board.find_square(8, king.rank).piece
    elsif move == 'O-O-O'
      side = :queenside
      rook = @board.find_square(1, king.rank).piece
    end
    moves = king.castle_moves[side]
    if @board.castle_is_legal?(king, rook, moves)
      @board.castle!(king, rook, side)
      end_turn
    else
      puts 'Cannot castle right now'
    end
  end

  def attempt_move(piece, target)
    piece.toggle_selected
    if @board.move_would_result_in_check?(piece, target)
      puts 'Cannot put yourself in check'
    elsif piece.can_move_to? target
      piece.move_to target
      end_turn
    else
      puts 'Invalid move'
    end
  end

  def end_turn
    switch_players
    assess_board_for_check
  end

  def switch_players
    @current_player = if @current_player.equal?(@players[:white])
                        @players[:black]
                      else
                        @players[:white]
                      end
  end

  def clear_en_passant
    Pawn.all.each do |pawn|
      pawn.is_en_passant_capturable = false if pawn.colour == @current_player.colour
    end
  end

  def game_over
    @board.to_s
    puts "#{@current_player} wins!"
    exit
  end

  def alpha_to_num(letter)
    letter.upcase.ord - 'A'.ord + 1
  end
end
