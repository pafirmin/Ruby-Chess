require_relative('./lib/display')
require_relative('./lib/pieces/piece')
require_relative('./lib/pieces/king')
require_relative('./lib/pieces/queen')
require_relative('./lib/pieces/bishop')
require_relative('./lib/pieces/knight')
require_relative('./lib/pieces/rook')
require_relative('./lib/pieces/pawn')
require_relative('./lib/board')
require_relative('./lib/player')
require_relative('./lib/square')
require_relative('./lib/prompts')
require_relative('./lib/save_manager')
require_relative('./lib/game')
require 'colorize'

game = Game.new
game.run
