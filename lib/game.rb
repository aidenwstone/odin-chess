# frozen_string_literal: true

require './lib/board'
require 'colorize'

# The Game class manages a game of chess, keeping track of the current player, asking for input,
# and announcing a winner. It also handles the saving/loading of games.
class Game # rubocop:disable Metrics/ClassLength
  SAVE_PATH = 'dump/saved_game.dat'
  NOTATION_FORMAT = /(?<file>[a-h])(?<rank>[1-8])/.freeze
  FILE_TO_NUM = ('a'..'h').each_with_index.to_h
  MESSAGE_TYPE_TO_COLOR = {
    standard: :default,
    warning: :red,
    announcement: :green
  }.freeze
  PROMOTION_PIECE_CLASSES = {
    queen: Queen,
    knight: Knight,
    bishop: Bishop,
    rook: Rook
  }.freeze

  attr_reader :board, :current_player

  def initialize
    @board = Board.new
    @current_player = :white
  end

  def play
    loop do
      board.show(current_player)
      play_turn
      switch_player

      result = game_result
      break announce_result(result) if result
    end
  end

  def switch_player
    @current_player = other_player
  end

  def choose_start_square # rubocop:disable Metrics/AbcSize
    show_message('Tip: You can save the game at this point by entering "quit" instead of selecting a piece.',
                 type: :announcement)

    loop do
      input = ask_for_input("#{current_player.capitalize}, please select which piece to move using chess notation (e.g. b3 or f5):") # rubocop:disable Layout/LineLength
      return if input == 'quit'

      square = notation_to_coordinates(input)
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

  def choose_promotion_piece
    loop do
      piece_selection = ask_for_input("#{current_player.capitalize}, select a piece to promote your pawn to (Queen, Knight, Bishop, Rook):") # rubocop:disable Layout/LineLength

      piece_class = PROMOTION_PIECE_CLASSES[piece_selection.to_sym]
      return piece_class.new(current_player) if piece_class

      show_message('Invalid selection, please try again.', type: :warning)
    end
  end

  private

  def play_turn
    start_square = choose_start_square
    save_and_quit unless start_square

    target_square = choose_target_square(start_square)
    board.move_piece(start_square, target_square)
    promote(target_square) if @board.should_promote?(target_square)
  end

  def save_and_quit
    serialized_game = Marshal.dump(self)
    File.binwrite(SAVE_PATH, serialized_game)
    show_message('The game was saved!', type: :announcement)
    exit
  end

  def other_player
    current_player == :white ? :black : :white
  end

  def show_message(message, type: :standard)
    color = MESSAGE_TYPE_TO_COLOR[type]

    puts "\n#{message}".colorize(color)
  end

  def ask_for_input(message)
    show_message(message)
    gets.chomp.downcase
  end

  def notation_to_coordinates(notation)
    match_data = notation.match(NOTATION_FORMAT)

    return if match_data.nil?

    column = FILE_TO_NUM[match_data[:file]]
    row = match_data[:rank].to_i - 1

    [row, column]
  end

  def promote(square)
    @board.show(current_player)
    promotion_piece = choose_promotion_piece
    board.place_piece(promotion_piece, *square)
  end

  def game_result
    if board.checkmate?(current_player)
      :checkmate
    elsif board.stalemate?(current_player)
      :stalemate
    elsif board.threefold_repetition?
      :threefold_repetition
    elsif board.insufficient_material?
      :insufficient_material
    end
  end

  def result_message(result)
    case result
    when :checkmate then "Checkmate! The winner is #{other_player.capitalize}."
    when :stalemate then 'Stalemate! No one wins.'
    when :threefold_repetition then 'Threefold repetition! No one wins.'
    when :insufficient_material then 'Insufficient mating material! No one wins.'
    end
  end

  def announce_result(result)
    @board.show(other_player)
    show_message(result_message(result), type: :announcement)
  end
end
