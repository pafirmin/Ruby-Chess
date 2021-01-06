require 'yaml'

module SaveManager
	def save_game(game)
    File.open('save.yml', 'w') { |file| file.write(game.to_yaml) }
    puts 'Game saved'
	end

  def load_game
    game = YAML.load(File.read('save.yml'))
    puts 'Game loaded'
    game.turn_loop
	end
end
