# Utilities for Player class and Game Class
class Utilities
  # --------------------------------------------------------------------------
  def initialize
  end

  # --------------------------------------------------------------------------
  def dice_roll(n)
    values = []
    n.times do
      values += [Random.rand(6) + 1]
    end
    values
  end

  # --------------------------------------------------------------------------
  def to_frequency(dice)
    # Store frequency of each dice value
    frequency = Hash.new(0)
    dice.each do |i|
      frequency[i] += 1
    end
    frequency
  end

  # --------------------------------------------------------------------------
  def score(dice)
    # Variable to store the final score value
    final_score = 0
    frequency = to_frequency(dice)
    frequency.each do |k, v|
      triplets = v / 3
      residue = v % 3
      if k == 1
        # Handles both cases for 1
        final_score += residue * 100
        final_score += 1000 * triplets
      else
        # Handles cases for non-scoring values
        final_score += 100 * triplets * k
        # Handles both cases for 5
        final_score += residue * 50 if k == 5
      end
    end

    final_score
  end

  # --------------------------------------------------------------------------
  def get_non_scoring(dice_values)
    # Store frequency of each dice value
    frequency = to_frequency(dice_values)
    non_scoring = dice_values.length

    frequency.each do |k, v|
      triplets = v / 3
      residue = v % 3
      # Subtract number of triplets
      non_scoring -= triplets * 3
      non_scoring -= residue if k == 1 || k == 5
    end
    non_scoring
  end
end
