class Board
    attr_accessor :squares

    def initialize
        @squares = [['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|'],
        ['_|' '_|' '_|' '_|' '_|' '_|' '_|' '_|']]
    end


    def create_board

    end

end

board = Board.new
board[5][6]

puts board.squares

def valid_move
    tmp_square = piece.current_square
    for i in piece.valid_moves
        loop do
            tmp_square = board
            tmp = 
end