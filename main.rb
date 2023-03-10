# frozen_string_literal: true

# Class shows state of game board
class Board
  attr_reader :board
  attr_accessor :move_board

  def initialize
    @board = [[1, ' | ', 2, ' | ', 3], [4, ' | ', 5, ' | ', 6], [7, ' | ', 8, ' | ', 9]]
    @move_board = board.map(&:clone)
  end

  def to_s
    " #{move_board.first.join}\n #{move_board[1].join}\n #{move_board.last.join}"
  end

  def board_for_check
    @move_board.map do |arr|
      arr.reject { |element| element == ' | ' }
    end
  end

  def process_player_move(player_sign, move)
    move_board.map! do |arr|
      index = arr.find_index(move)
      arr[index] = player_sign if arr.include?(move)
      arr
    end
    puts self
  end
end

# Class shows state of player
class Player
  attr_reader :name, :sign

  def initialize(name, sign)
    @name = name
    @sign = sign
  end

  def to_s
    "Player: #{name}, sign: #{sign}."
  end

  def make_move
    input = gets.chomp
    unless input.match?(/[[:digit:]]/) && PlayGame::BOARD.move_board.any? { |arr| arr.include?(input.to_i) } == true
      raise InvalidInput, 'Invalid input. Use a different number!'
    end
  rescue InvalidInput => e
    puts e
    retry
  else
    input.to_i
  end
end

class InvalidInput < StandardError; end

# This module implements game rounds and winner check
module PlayGame
  BOARD = Board.new

  def self.first_player_move
    puts "#{CreatePlayer::FIRST_PLAYER.name} make your move!"
    BOARD.process_player_move(CreatePlayer::FIRST_PLAYER.sign, CreatePlayer::FIRST_PLAYER.make_move)
  end

  def self.second_player_move
    puts "#{CreatePlayer::SECOND_PLAYER.name} make your move!"
    BOARD.process_player_move(CreatePlayer::SECOND_PLAYER.sign, CreatePlayer::SECOND_PLAYER.make_move)
  end

  def self.check_left_moves
    return unless BOARD.move_board.any? { |arr| arr.any?(Integer) } == false

    puts 'It\'s a draw!'
    true
  end

  def self.first_player_won
    "Congratulations! #{CreatePlayer::FIRST_PLAYER.name} won the game!"
  end

  def self.second_player_won
    "Congratulations! #{CreatePlayer::SECOND_PLAYER.name} won the game!"
  end

  def self.first_column
    [].push(BOARD.board_for_check[0][0], BOARD.board_for_check[1][0], BOARD.board_for_check[2][0])
  end

  def self.second_column
    [].push(BOARD.board_for_check[0][1], BOARD.board_for_check[1][1], BOARD.board_for_check[2][1])
  end

  def self.third_column
    [].push(BOARD.board_for_check[0][2], BOARD.board_for_check[1][2], BOARD.board_for_check[2][2])
  end

  def self.left_diagonal
    [].push(BOARD.board_for_check[0][0], BOARD.board_for_check[1][1], BOARD.board_for_check[2][2])
  end

  def self.right_diagonal
    [].push(BOARD.board_for_check[0][2], BOARD.board_for_check[1][1], BOARD.board_for_check[2][0])
  end

  def self.check_arr(first_column, second_column, third_column, left_diagonal, right_diagonal)
    check_arr = BOARD.board_for_check.push(first_column, second_column, third_column, left_diagonal, right_diagonal)
    check_arr.any? do |arr|
      if arr.all?(CreatePlayer::FIRST_PLAYER.sign)
        puts first_player_won
        return true
      elsif arr.all?(CreatePlayer::SECOND_PLAYER.sign)
        puts second_player_won
        return true
      end
    end
  end

  def self.winner_check
    return unless check_arr(first_column, second_column, third_column, left_diagonal, right_diagonal)\
    || check_left_moves

    true
  end

  def self.play_again
    puts 'Do you want to play again?(yes or anything)'
    answer = gets.chomp
    return unless answer.downcase == 'yes'

    BOARD.move_board = BOARD.board.map(&:clone)
    play_game
  end

  def self.play_game
    puts BOARD
    loop do
      first_player_move
      break if winner_check

      second_player_move
      break if winner_check
    end
    play_again
  end
end

# This module creates new players
module CreatePlayer
  def self.input
    gets.chomp
  end

  def self.set_sign
    sign = input
    if defined?(FIRST_PLAYER) == 'constant' && FIRST_PLAYER.sign == sign || sign.match?(/[[:digit:]]/)\
      || sign.length > 1 || sign.match?(/\W+/)
      raise InvalidInput, 'Invalid input. Use a different letter!'
    end
  rescue InvalidInput => e
    puts e
    retry
  else
    sign
  end

  def self.ask_name
    if defined?(FIRST_PLAYER) == 'constant'
      'Enter the second player name'
    else
      'Enter the first player name'
    end
  end

  def self.ask_sign
    if defined?(FIRST_PLAYER) == 'constant'
      "Enter a letter for the second player\'s sign\n"\
      "It mustn't be #{FIRST_PLAYER.sign}"
    else
      'Enter a letter for the first player\'s sign'
    end
  end

  def self.create_player
    puts ask_name

    name = input

    puts ask_sign

    sign = set_sign

    Player.new(name, sign)
  end

  FIRST_PLAYER = create_player
  SECOND_PLAYER = create_player
end

puts  CreatePlayer::FIRST_PLAYER

puts  CreatePlayer::SECOND_PLAYER

PlayGame.play_game
