# -----------------------------------------------------------------------------
def dice_roll(n)
    values = []
    n.times do
        values += [Random.rand(6) + 1]
    end
    return values
end

# -----------------------------------------------------------------------------
def score(dice)

    # Variable to store the final score value
    final_score = 0

    # Store frequency of each dice value
    frequency = Hash.new(0)
    dice.each do |i|
        frequency[i] += 1
    end

    frequency.each do |k, v|
        triplets = v / 3
        residue = v % 3
        if k == 1
            # Handles both cases for 1
            final_score += residue * 100
            final_score += 1000 * triplets
        elsif k == 5
            # Handles both cases for 5
            final_score += residue * 50
            final_score += 100 * triplets * k
        else
            # Handles cases for non-scoring values
            final_score += 100 * triplets * k
        end
    end

    return final_score
end

# -----------------------------------------------------------------------------
def get_non_scoring(dice_values)
    # Store frequency of each dice value
    frequency = Hash.new(0)
    dice_values.each do |i|
        frequency[i] += 1
    end

    non_scoring = dice_values.length

    frequency.each do |k, v|
        triplets = v / 3
        residue = v % 3
        # Subtract number of triplets
        non_scoring -= triplets * 3
        if k == 1 || k == 5
            non_scoring -= residue
        end
    end

    return non_scoring
end

# -----------------------------------------------------------------------------
class Player

    attr_reader :total_score, :is_active

    # -------------------------------------------------------------------------
    def initialize
        @total_score = 0
        @is_active = false
    end

    # -------------------------------------------------------------------------
    def roll_dice(old_turn_score, current_available)

        # Roll the available number of dices
        dice_values = dice_roll(current_available)

        # Update the turn_score
        current_roll_score = score(dice_values)

        turn_score = old_turn_score + current_roll_score
        # Just for the purpose of consistent logging
        turn_score = 0 if current_roll_score == 0

        puts "Current dice values: " + dice_values.join(" ")
        puts "Current turn score: #{turn_score}"
        puts "Total score: #{@total_score}"

        return dice_values, turn_score

    end

    # -------------------------------------------------------------------------
    def play_my_turn(number_of_dices)
        # Returns score of the current turn and
        # also updates his/her total score

        allowed_dices = number_of_dices
        current_available = number_of_dices
        turn_score = 0

        while current_available > 0

            # Ask if player is happy with the current turn score
            # and does not want to be greedy for more score
            puts "Do you want to play more? (y/n): "
            play_more = gets.strip

            if play_more == "n"
                turn_score = 0 if @is_active == false
                @total_score += turn_score
                puts "Total score: #{@total_score}"
                return turn_score
            end

            dice_values, turn_score = roll_dice(turn_score, current_available)

            # If a roll scores 0, score of complete turn is 0
            return 0 if turn_score == 0

            # Update is_active if turn_score exceeded 300
            if @is_active == false
                @is_active = (turn_score >= 300)
            end

            # Update the current available dices for next hand
            current_available = get_non_scoring(dice_values)

            # Check if all the dices were scoring
            current_available = allowed_dices if current_available == 0

            puts "Current available #{current_available}"

        end

        turn_score = 0 if @is_active == false
        # Update total_score of this player
        @total_score += turn_score
        puts "Total score: #{@total_score}"

        return turn_score
    end
end

# -----------------------------------------------------------------------------
class Game

    attr_accessor :total_score
    attr_reader :winner
    attr_reader :number_of_players
    attr_reader :players

    # -------------------------------------------------------------------------
    def initialize(number_of_players)

        if number_of_players < 2
            raise RuntimeError, "Atleast 2 players are required to play the game"
        end

        @number_of_players = number_of_players
        @number_of_dices = 5
        # All the player objects
        @players = Array.new(@number_of_players)
        # Total score of players
        @total_score = Array.new(@number_of_players)

        for i in 0...@number_of_players
            @players[i] = Player.new
            @total_score[i] = 0
        end

        # Will be updated only after the game is over
        @winner = []

    end

    # -------------------------------------------------------------------------
    def update_total_score(i)

        puts i
        puts "Player #{i + 1}"
        @total_score[i] += @players[i].play_my_turn(@number_of_dices)
        puts "***********************************************"
        puts @total_score

    end

    # -------------------------------------------------------------------------
    def get_results

        puts "GAME COMPLETE"
        indices = @total_score.each_index.select{|i| @total_score[i] == @total_score.max}
        indices.map { |i| i + 1 }

    end

    # -------------------------------------------------------------------------
    def play_game

        iteration = 1
        break_index = catch(:lastround) do
            while true
                puts "Playing iteration number #{iteration}"
                iteration += 1
                for i in 0...@number_of_players
                    update_total_score(i)
                    throw(:lastround, i) if @total_score[i] >= 3000
                end
                puts "\n\n------------------------------------------\n\n"
            end
        end

        for i in (break_index + 1)...@number_of_players
            update_total_score(i)
        end

        @winner = get_results()
        puts "Winner: #{@winner.join(" ")}"
    end

end

if __FILE__ == $0
    puts "Enter number of players: "
    players = gets.strip.to_i

    game = Game.new(players)
    game.play_game
end

# END===========================================================================
