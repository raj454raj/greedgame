# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

# -----------------------------------------------------------------------------

class DiceSet
    attr_accessor :values

    # -------------------------------------------------------------------------
    def initialize
        @values = []
    end

    # -------------------------------------------------------------------------
    def roll(n)
        @values = []
        n.times do
            @values += [Random.rand(6) + 1]
        end
    end
end

$dice = DiceSet.new

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
        # Subtract number
        non_scoring -= triplets * 3
        if k == 1 || k == 5
            non_scoring -= residue
        end
    end

    return non_scoring

    dice_values.select{ |a| a != 1 && a != 5 }.length
end

# -----------------------------------------------------------------------------
class Player

    # -------------------------------------------------------------------------
    def initialize
        @total_score = 0
        @is_active = false
    end

    # -------------------------------------------------------------------------
    def play_my_turn(number_of_dices)
        # Returns score of the current turn and
        # also updates his/her total score
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

            # Roll the available number of dices
            $dice.roll(current_available)

            # Update the turn_score
            dice_values = $dice.values

            current_roll_score = score(dice_values)
            turn_score += current_roll_score

            # Just for the purpose of consistent logging
            turn_score = 0 if current_roll_score == 0

            puts "Current dice values: " + dice_values.join(" ")
            puts "Current turn score: #{turn_score}"
            puts "Total score: #{@total_score}"

            if current_roll_score == 0
                # If a roll scores 0, score of complete turn is 0
                return 0
            end

            # Update is_active if turn_score exceeded 300
            if @is_active == false
                @is_active = (turn_score >= 300)
            end

            # Update the current available dices for next hand
            current_available = get_non_scoring(dice_values)
            puts "Current available #{current_available}"

            # Check if all the dices were scoring
            if current_available == dice_values.length
                turn_score = 0 if @is_active == false
                return turn_score
            end

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

    # -------------------------------------------------------------------------
    def initialize(number_of_players)
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

    end

    # -------------------------------------------------------------------------
    def play_game

        iteration = 1

        break_index = catch(:lastround) do

            while true

                puts "Playing iteration number #{iteration}"
                iteration += 1

                for i in 0...@number_of_players
                    puts "Player #{i + 1}"
                    @total_score[i] += @players[i].play_my_turn(@number_of_dices)
                    puts "***************************************"
                    throw(:lastround, i) if @total_score[i] >= 3000
                    p @total_score
                end

                puts "\n\n------------------------------------------\n\n"

            end

        end

        for i in (break_index + 1)...@number_of_players
            puts "Player #{i + 1}"
            @total_score[i] += @players[i].play_my_turn(@number_of_dices)
            p @total_score
            puts "***************************************"
        end
        puts "GAME COMPLETE"
    end

end

puts "Enter number of players: "
players = gets.strip().to_i

if players > 1
    game = Game.new(players)
    game.play_game
else
    puts "Insufficient players to start the game"
end

# END===========================================================================
