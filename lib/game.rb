# frozen_string_literal: true

require './lib/board'

# The Game class manages a game of chess, keeping track of the current player, asking for input,
# and announcing a winner. It also handles the saving/loading of games.
class Game
  NOTATION_FORMAT = /(?<file>[a-h])(?<rank>[1-8])/.freeze
  FILE_TO_NUM = ('a'..'h').each_with_index.to_h

  attr_reader :board, :current_player

  def initialize
    @board = Board.new
    @current_player = :white
  end

  def switch_player
    @current_player = current_player == :white ? :black : :white
  end

  def choose_start_square
    loop do
      notation_selection = ask_for_input('Please select which piece to move using chess notation (e.g. b3 or f5):')
      square = notation_to_coordinates(notation_selection)

      return square unless square.nil? || board.legal_moves(square).empty?

      puts 'Invalid selection, please try again.'
    end
  end

  def choose_target_square(start_square)
    loop do
      notation_selection = ask_for_input('Please select which square to move to using chess notation (e.g. b3 or f5):')
      square = notation_to_coordinates(notation_selection)
      legal_moves = board.legal_moves(start_square)

      return square if legal_moves.include?(square)

      puts 'Invalid selection, please try again.'
    end
  end

  private

  def ask_for_input(message)
    puts message
    gets.chomp
  end

  def notation_to_coordinates(notation)
    match_data = notation.match(NOTATION_FORMAT)

    return if match_data.nil?

    column = FILE_TO_NUM[match_data[:file]]
    row = match_data[:rank].to_i - 1

    [row, column]
  end
end
