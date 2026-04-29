# frozen_string_literal: true

require './lib/board'
require 'colorize'

# The Game class manages a game of chess, keeping track of the current player, asking for input,
# and announcing a winner. It also handles the saving/loading of games.
class Game
  NOTATION_FORMAT = /(?<file>[a-h])(?<rank>[1-8])/.freeze
  FILE_TO_NUM = ('a'..'h').each_with_index.to_h
  MESSAGE_TYPE_TO_COLOR = {
    standard: :default,
    warning: :red,
    announcement: :green
  }.freeze

  attr_reader :board, :current_player

  def initialize
    @board = Board.new
    @current_player = :white
  end

  def switch_player
    @current_player = other_player
  end

  def choose_start_square
    loop do
      notation_selection = ask_for_input("#{current_player.capitalize}, please select which piece to move using chess notation (e.g. b3 or f5):") # rubocop:disable Layout/LineLength
      square = notation_to_coordinates(notation_selection)
      piece = board.piece_on(square) unless square.nil?

      return square unless square.nil? || board.legal_moves(square).empty? || piece.color != current_player

      show_message('Invalid selection, please try again.', type: :warning)
    end
  end

  def choose_target_square(start_square)
    loop do
      notation_selection = ask_for_input('Now select which square to move to:')
      square = notation_to_coordinates(notation_selection)
      legal_moves = board.legal_moves(start_square)

      return square if legal_moves.include?(square)

      show_message('Invalid selection, please try again.', type: :warning)
    end
  end

  private

  def other_player
    current_player == :white ? :black : :white
  end

  def show_message(message, type: :standard)
    color = MESSAGE_TYPE_TO_COLOR[type]

    puts "\n#{message}".colorize(color)
  end

  def ask_for_input(message)
    show_message(message)
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
