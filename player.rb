require_relative 'utilities'

# -----------------------------------------------------------------------------
# Player class that handles playing turns of a single player
class Player
  attr_reader :total_score
  attr_accessor :is_active

  # -------------------------------------------------------------------------
  def initialize
    @total_score = 0
    @is_active = false
  end

  # -------------------------------------------------------------------------
  def roll_dice(old_turn_score, current_available, utilities)
    # Roll the available number of dices
    dice_values = utilities.dice_roll(current_available)

    # Update the turn_score
    current_roll_score = utilities.score(dice_values)

    turn_score = old_turn_score + current_roll_score
    # Just for the purpose of consistent logging
    turn_score = 0 if current_roll_score == 0

    puts 'Current dice values: ' + dice_values.join(' ')
    puts "Current turn score: #{turn_score}"
    puts "Total score: #{@total_score}"

    [dice_values, turn_score]
  end

  # -------------------------------------------------------------------------
  def process_user_input(turn_score)
    # Ask if player is happy with the current turn score
    # and does not want to be greedy for more score
    puts 'Do you want to play more? ([Y]/n): '
    play_more = gets.strip

    if play_more == 'n'
      turn_score = 0 if @is_active == false
      @total_score += turn_score
      puts "Total score: #{@total_score}"
      return false
    end
    true
  end

  # -------------------------------------------------------------------------
  def play_my_turn(number_of_dices)
    # Returns score of the current turn and
    # also updates his/her total score

    allowed_dices = number_of_dices
    current_available = number_of_dices
    turn_score = 0
    utilities = Utilities.new

    while current_available > 0
      continue_playing = process_user_input(turn_score)
      return turn_score if continue_playing == false
      dice_values, turn_score = roll_dice(turn_score,
                                          current_available,
                                          utilities)

      # If a roll scores 0, score of complete turn is 0
      return 0 if turn_score == 0

      # Update is_active if turn_score exceeded 300
      @is_active = (turn_score >= 300) if @is_active == false

      # Update the current available dices for next hand
      current_available = utilities.get_non_scoring(dice_values)

      # Check if all the dices were scoring
      current_available = allowed_dices if current_available == 0

      puts "Current available #{current_available}"
    end

    turn_score = 0 if @is_active == false
    # Update total_score of this player
    @total_score += turn_score
    puts "Total score: #{@total_score}"

    turn_score
  end
end
