# frozen_string_literal: true

require './lib/rook'
require './lib/knight'
require './lib/bishop'
require './lib/queen'
require './lib/king'
require './lib/pawn'

# The Board class manages the state of the chessboard, keeping track of where pieces are as well as providing
# information such as whether or not a given move is legal.
class Board # rubocop:disable Metrics/ClassLength
  BACK_RANK = %i[rook knight bishop queen king bishop knight rook].freeze
  FILE_LABELS = %i[a b c d e f g h].freeze

  attr_reader :grid

  def initialize(setup: :standard)
    @grid = Array.new(8) { Array.new(8) }

    return if setup == :empty

    # Place pieces in the back rank for each player
    @grid[0] = BACK_RANK.map { |type| build_piece(type, :white) }
    @grid[7] = BACK_RANK.map { |type| build_piece(type, :black) }

    # Place Pawns for each player
    @grid[1] = Array.new(8) { build_piece(:pawn, :white) }
    @grid[6] = Array.new(8) { build_piece(:pawn, :black) }
  end

  def place_piece(piece, row, col)
    raise(ArgumentError, 'invalid coordinates') unless row.between?(0, 7) && col.between?(0, 7)

    @grid[row][col] = piece
  end

  def remove_piece(row, col)
    raise(ArgumentError, 'invalid coordinates') unless row.between?(0, 7) && col.between?(0, 7)

    piece = @grid[row][col]
    raise('empty square') if piece.nil?

    @grid[row][col] = nil

    piece
  end

  def show(perspective)
    board_view = rows_for(perspective)

    draw_file_labels(perspective)
    board_view.each_with_index do |row, index|
      draw_divider_line
      draw_row(perspective, row, index)
    end
    draw_divider_line
    draw_file_labels(perspective)
  end

  def available_moves(start_square)
    piece = @grid.dig(*start_square)

    if piece.instance_of?(Pawn)
      pawn_movements(piece, start_square)
    elsif piece.movement_type == :sliding
      sliding_movements(piece, start_square)
    elsif piece.movement_type == :stepping
      stepping_movements(piece, start_square)
    end
  end

  private

  def build_piece(type, color)
    case type
    when :rook   then Rook.new(color)
    when :knight then Knight.new(color)
    when :bishop then Bishop.new(color)
    when :queen  then Queen.new(color)
    when :king   then King.new(color)
    when :pawn   then Pawn.new(color)
    end
  end

  def rows_for(perspective)
    perspective == :white ? @grid.reverse : @grid
  end

  def draw_file_labels(perspective)
    labels = perspective == :white ? FILE_LABELS : FILE_LABELS.reverse

    puts "    #{labels.join('   ')}"
  end

  def draw_divider_line
    puts '  +---+---+---+---+---+---+---+---+'
  end

  def draw_row(perspective, row, index)
    squares = row.map { |char| char || ' ' }
    rank = rank_label(perspective, index)

    puts "#{rank} | #{squares.join(' | ')} | #{rank}"
  end

  def rank_label(perspective, index)
    perspective == :white ? 8 - index : index + 1
  end

  def pawn_movements(piece, start_square)
    piece.moves.each_with_object([]) do |vector, squares|
      new_square = start_square.zip(vector).map(&:sum)

      return squares unless on_board?(new_square) && square_available?(new_square)

      squares << new_square
    end
  end

  def sliding_movements(piece, start_square)
    piece.moves.each_with_object([]) do |direction, squares|
      (1..7).each do |step|
        vector = direction.map { |delta| delta * step }
        new_square = start_square.zip(vector).map(&:sum)

        break unless on_board?(new_square) && square_available?(new_square)

        squares << new_square
      end
    end
  end

  def stepping_movements(piece, start_square)
    piece.moves.filter_map do |vector|
      new_square = start_square.zip(vector).map(&:sum)
      new_square if on_board?(new_square) && square_available?(new_square)
    end
  end

  def on_board?(square)
    row, col = square
    row.between?(0, 7) && col.between?(0, 7)
  end

  def square_available?(square)
    @grid.dig(*square).nil?
  end
end
