require_relative 'player'

# -----------------------------------------------------------------------------
# Game class which handles playing of entire game
class Game
  attr_accessor :total_score
  attr_reader :winner
  attr_reader :number_of_players
  attr_reader :players

  # -------------------------------------------------------------------------
  def initialize(number_of_players)
    raise RuntimeError if number_of_players < 2

    @number_of_players = number_of_players
    @number_of_dices = 5
    # All the player objects
    @players = Array.new(@number_of_players)
    # Total score of players
    @total_score = Array.new(@number_of_players)

    @number_of_players.times do |i|
      @players[i] = Player.new
      @total_score[i] = 0
    end

    # Will be updated only after the game is over
    @winner = []
  end

  # -------------------------------------------------------------------------
  def update_total_score(i)
    puts "Player #{i + 1}"
    @total_score[i] += @players[i].play_my_turn(@number_of_dices)
    puts '***********************************************'
    puts 'Total scores: ' + @total_score.join(' ')
  end

  # -------------------------------------------------------------------------
  def obtain_results
    puts 'GAME COMPLETE'
    indices = @total_score.each_index.select do |i|
      @total_score[i] == @total_score.max
    end
    indices.map { |i| i + 1 }
  end

  # -------------------------------------------------------------------------
  def play_game
    break_index = catch(:lastround) do
      loop do
        @number_of_players.times do |i|
          update_total_score(i)
          throw(:lastround, i) if @total_score[i] >= 3000
        end
        puts "\n\n------------------------------------------\n\n"
      end
    end

    ((break_index + 1)...@number_of_players).each do |i|
      update_total_score(i)
    end

    @winner = obtain_results
    puts "Winner: #{@winner.join(' ')}"
  end
end

if __FILE__ == $PROGRAM_NAME
  puts 'Enter number of players: '
  players = gets.strip.to_i

  game = Game.new(players)
  game.play_game
end

# END===========================================================================
