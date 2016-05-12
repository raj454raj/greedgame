require_relative 'game'

describe Utilities do
  describe 'Utilities#to_frequency' do
    before do
      @utilities = Utilities.new
    end

    it 'can compute a frequency hash' do
      expected = { 1 => 2, 2 => 1, 3 => 1, 4 => 3 }
      expect(@utilities.to_frequency([1, 1, 2, 3, 4, 4, 4])).to eql(expected)
    end

    it 'can compute a frequency hash for empty input' do
      expect(@utilities.to_frequency([])).to eql({})
    end
  end

  describe 'Utilities#dice_roll' do
    before do
      @utilities = Utilities.new
    end

    it 'values is an array' do
      expect(@utilities.dice_roll(5).is_a?(Array)).to eq true
    end

    it 'can generate list of values with fixed length' do
      expect(@utilities.dice_roll(5).length).to eq 5
    end

    it 'can generate the numbers in the range 1 to 6' do
      # Try rolling 10 times
      10.times do
        values = @utilities.dice_roll(5)
        5.times do |i|
          expect(values[i]).to be >= 1
          expect(values[i]).to be <= 6
        end
      end
    end
  end

  describe 'Utilities#score' do
    before do
      @utilities = Utilities.new
    end

    it 'can get score for three 1s' do
      expect(@utilities.score([1, 1, 1, 2, 3])).to eq 1000
      expect(@utilities.score([1, 2, 1, 3, 1])).to eq 1000
    end

    it 'can get score for triplets except that of 1s' do
      expect(@utilities.score([2, 2, 4, 2, 3])).to eq 200
      expect(@utilities.score([3, 4, 4, 3, 3])).to eq 300
      expect(@utilities.score([4, 4, 4, 3, 2])).to eq 400
      expect(@utilities.score([5, 4, 5, 5, 2])).to eq 500
      expect(@utilities.score([4, 6, 6, 6, 2])).to eq 600
    end

    it 'can get score for 1s not part of triplets' do
      expect(@utilities.score([4, 4, 1, 2, 3])).to eq 100
      expect(@utilities.score([1, 1, 1, 2, 1])).to eq 1100
    end

    it 'can get score for 5s not part of triplets' do
      expect(@utilities.score([5, 4, 5, 6, 6])).to eq 100
      expect(@utilities.score([2, 4, 5, 6, 6])).to eq 50
      expect(@utilities.score([5, 5, 5, 5, 6])).to eq 550
    end

    it 'can get score for 1s and 5s both not as part of triplets' do
      expect(@utilities.score([1, 1, 5, 6, 4])).to eq 250
      expect(@utilities.score([5, 1, 5, 6, 4])).to eq 200
    end

    it 'can get score for all non scoring numbers' do
      expect(@utilities.score([2, 3, 6, 4, 4])).to eq 0
      expect(@utilities.score([3, 2, 6, 4, 2])).to eq 0
    end
  end

  describe 'Utilities#get_non_scoring' do
    before do
      @utilities = Utilities.new
    end

    it 'can get non-scoring in case of triplets' do
      expect(@utilities.get_non_scoring([1, 2, 1, 2, 1])).to eq 2
      expect(@utilities.get_non_scoring([2, 2, 1, 2, 1])).to eq 0
      expect(@utilities.get_non_scoring([2, 2, 1, 2, 1])).to eq 0
    end

    it 'can get non-scoring in case of no scoring values' do
      expect(@utilities.get_non_scoring([2, 4, 4, 3, 3])).to eq 5
    end

    it 'can get non-scoring in case of more than 3 scoring values' do
      expect(@utilities.get_non_scoring([1, 1, 1, 1, 1])).to eq 0
      expect(@utilities.get_non_scoring([1, 1, 1, 1, 4])).to eq 1
      expect(@utilities.get_non_scoring([1, 1, 1, 1, 5])).to eq 0
      expect(@utilities.get_non_scoring([1, 1, 1, 5, 5])).to eq 0
      expect(@utilities.get_non_scoring([2, 2, 2, 5, 5])).to eq 0
      expect(@utilities.get_non_scoring([2, 2, 2, 1, 5])).to eq 0
      expect(@utilities.get_non_scoring([2, 2, 2, 4, 5])).to eq 1
    end

    it 'can get non-scoring in case of less than 3 scoring values' do
      expect(@utilities.get_non_scoring([1, 3, 4, 4, 2])).to eq 4
      expect(@utilities.get_non_scoring([1, 1, 4, 4, 2])).to eq 3
      expect(@utilities.get_non_scoring([1, 5, 4, 4, 2])).to eq 3
      expect(@utilities.get_non_scoring([3, 5, 4, 4, 2])).to eq 4
    end
  end
end

describe Player do
  before do
    @player = Player.new
    allow(STDOUT).to receive(:puts)
  end

  it 'can roll a dice' do
    utilities = Utilities.new
    allow(utilities).to receive(:dice_roll).and_return([1, 2, 3, 1, 5])
    _, actual_score = @player.roll_dice(100, 5, utilities)
    expect(actual_score).to eq(350)

    allow(utilities).to receive(:dice_roll).and_return([4, 2, 3, 1, 5])
    _, actual_score = @player.roll_dice(100, 5, utilities)
    expect(actual_score).to eq(250)

    allow(utilities).to receive(:dice_roll).and_return([4, 2, 3])
    _, actual_score = @player.roll_dice(100, 3, utilities)
    expect(actual_score).to eq(0)

    allow(utilities).to receive(:dice_roll).and_return([5, 2, 3])
    _, actual_score = @player.roll_dice(100, 3, utilities)
    expect(actual_score).to eq(150)

    allow(utilities).to receive(:dice_roll).and_return([1, 1, 1])
    _, actual_score = @player.roll_dice(1000, 3, utilities)
    expect(actual_score).to eq(2000)
  end

  it 'can process user input anything except n' do
    previous_score = @player.total_score
    allow(@player).to receive(:gets).and_return("y\n")
    expect(@player.process_user_input(300)).to eq(true)
    expect(@player.total_score).to eq(previous_score)

    allow(@player).to receive(:gets).and_return("Y\n")
    expect(@player.process_user_input(300)).to eq(true)
    expect(@player.total_score).to eq(previous_score)

    allow(@player).to receive(:gets).and_return("\n")
    expect(@player.process_user_input(300)).to eq(true)
    expect(@player.total_score).to eq(previous_score)
  end

  it 'can process user input n' do
    previous_score = @player.total_score
    allow(@player).to receive(:gets).and_return("n\n")
    expect(@player.process_user_input(300)).to eq(false)
    expect(@player.total_score).to eq(previous_score)

    @player.is_active = true
    expect(@player.process_user_input(300)).to eq(false)
    expect(@player.total_score).to eq(previous_score + 300)
  end

  it 'can play a turn with 300 barrier is cleared' do
    allow(@player).to receive(:gets).and_return("y\n", "y\n", "y\n",
                                                "y\n", "n\n")
    allow(@player).to receive(:roll_dice).and_return([[1, 2, 3, 5, 3], 150],
                                                     [[5, 2, 3], 200],
                                                     [[5, 5], 300],
                                                     [[1, 1, 4, 5, 2], 550])
    expect(@player.play_my_turn(5)).to eq(550)
    expect(@player.total_score).to eq(550)
    expect(@player.is_active).to eq(true)
  end

  it 'can play a turn without clearing the 300 barrier' do
    allow(@player).to receive(:gets).and_return("y\n", "y\n", "y\n")
    allow(@player).to receive(:roll_dice).and_return([[1, 2, 3, 5, 3], 150],
                                                     [[5, 2, 3], 200],
                                                     [[4, 4], 0])
    expect(@player.play_my_turn(5)).to eq(0)
    expect(@player.total_score).to eq(0)
    expect(@player.is_active).to eq(false)
  end

  it 'can play a turn with no scoring values' do
    allow(@player).to receive(:gets).and_return("y\n", "y\n")
    allow(@player).to receive(:roll_dice).and_return([[2, 4, 4, 6, 3], 0])
    expect(@player.play_my_turn(5)).to eq(0)
    expect(@player.total_score).to eq(0)
    expect(@player.is_active).to eq(false)
  end

  it 'can play a turn with exiting in the start' do
    allow(@player).to receive(:gets).and_return("n\n", "y\n")
    allow(@player).to receive(:roll_dice).and_return([[2, 4, 4, 6, 3], 0])
    expect(@player.play_my_turn(5)).to eq(0)
    expect(@player.total_score).to eq(0)
    expect(@player.is_active).to eq(false)
  end

  it 'can play after getting all the scoring values' do
    allow(@player).to receive(:gets).and_return("y\n", "y\n", "y\n", "n\n")
    allow(@player).to receive(:roll_dice).and_return([[3, 3, 3, 6, 2], 300],
                                                     [[1, 1], 500],
                                                     [[1, 2, 3, 4, 5], 650])
    expect(@player.play_my_turn(5)).to eq(650)
    expect(@player.total_score).to eq(650)
    expect(@player.is_active).to eq(true)
  end

  it 'can play two turns after getting previous accumulated total_score' do
    allow(@player).to receive(:gets).and_return("y\n", "y\n", "y\n", "n\n")
    allow(@player).to receive(:roll_dice).and_return([[3, 3, 3, 6, 2], 300],
                                                     [[1, 1], 500],
                                                     [[1, 2, 3, 4, 5], 650])
    expect(@player.play_my_turn(5)).to eq(650)
    expect(@player.total_score).to eq(650)
    expect(@player.is_active).to eq(true)

    allow(@player).to receive(:gets).and_return("y\n", "y\n", "n\n")
    allow(@player).to receive(:roll_dice).and_return([[3, 1, 3, 6, 2], 100],
                                                     [[1, 1, 4, 1], 1100])
    expect(@player.play_my_turn(5)).to eq(1100)
    expect(@player.total_score).to eq(1750)
    expect(@player.is_active).to eq(true)
  end

  it 'can cross the barrier in the second turn' do
    allow(@player).to receive(:gets).and_return("y\n")
    allow(@player).to receive(:roll_dice).and_return([[2, 4, 4, 6, 3], 0])
    expect(@player.play_my_turn(5)).to eq(0)
    expect(@player.total_score).to eq(0)
    expect(@player.is_active).to eq(false)

    allow(@player).to receive(:gets).and_return("y\n", "y\n", "n\n")
    allow(@player).to receive(:roll_dice).and_return([[3, 1, 3, 6, 2], 100],
                                                     [[1, 1, 4, 1], 1100])
    expect(@player.play_my_turn(5)).to eq(1100)
    expect(@player.total_score).to eq(1100)
    expect(@player.is_active).to eq(true)
  end
end

describe Game do
  before do
    @game = Game.new(2)
    allow(STDOUT).to receive(:puts)
  end

  it 'can raise error for invalid number of players (< 2)' do
    expect { Game.new(0) }.to raise_error(RuntimeError)
  end

  it 'can find a unique winner' do
    @game.total_score = [1, 2, 3, 4]
    expect(@game.obtain_results).to eq [4]
  end

  it 'can find more than one winners' do
    @game.total_score = [1, 3, 3]
    expect(@game.obtain_results).to eq [2, 3]
  end

  it 'can find winners if all of them have same score' do
    @game.total_score = [5, 5, 5, 5]
    expect(@game.obtain_results).to eq [1, 2, 3, 4]
  end

  it 'can stop the game after one of the user score has reached 3000' do
    @game.total_score = [3000, 500]
    @game.play_game
    expect(@game.winner).to eq [1]
  end

  it 'can stop the game after > 1 users\' score has reached 3000' do
    @game.total_score = [3000, 500, 3000]
    @game.play_game
    expect(@game.winner).to eq [1, 3]
  end

  it 'can give every player a turn' do
    @game.number_of_players.times do |i|
      allow(@game.players[i]).to receive(:play_my_turn).and_return(300)
      expect(@game).to receive(:update_total_score)
      @game.total_score[0] = 3000 if i == @game.number_of_players - 1
    end
    @game.play_game
  end
end
