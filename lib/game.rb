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
    @board.deploy_pieces
    @current_player = @players[:white]
    turn_loop
    game_over
	end
	
	def turn_loop
    until @checkmate
      clear_en_passant
      puts "#{@current_player}'s turn"
      puts @board.to_s
      piece = prompt_for_piece
      target = prompt_for_target
      attempt_move(piece, target)
    end
  end

  private

  def assess_board_for_check
    return unless @board.board_in_check?(@current_player.colour)
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
      square = choose_square
      if !square.friendly?(@current_player.colour)
        puts 'Please select a valid piece.'
      elsif square.piece.valid_moves.empty?
        puts 'Piece has no legal moves.'
      else
        return square.piece
      end
    end
  end

  def choose_square
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
      rook = @board.find_square(8, king.current_square.y).piece
    elsif move == 'O-O-O'
      side = :queenside
      rook = @board.find_square(1, king.current_square.y).piece
    end
    moves = king.castle_moves[side]
		if @board.can_castle?(king, rook, moves)
			@board.castle!(king, rook, side) 
			switch_players
			turn_loop
		else
			puts 'Cannot castle right now'
			turn_loop
		end
  end

  def alpha_to_num(letter)
    letter.upcase.ord - 'A'.ord + 1
  end

  def attempt_move(piece, target)
    if @board.move_would_put_self_in_check?(piece, target)
      puts 'Cannot put yourself in check'
      nil
    elsif piece.can_move_to?(target)
      piece.move_to(target)
      switch_players
      assess_board_for_check
    else
      puts 'Invalid move'
    end
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
end