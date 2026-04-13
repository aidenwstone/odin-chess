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

  def move_piece(start_square, target_square)
    piece = remove_piece(*start_square)
    place_piece(piece, *target_square)
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

  def available_attacks(start_square)
    piece = @grid.dig(*start_square)

    if piece.movement_type == :sliding
      sliding_attacks(piece, start_square)
    elsif piece.movement_type == :stepping
      stepping_attacks(piece, start_square)
    end
  end

  def check?(color)
    (0..7).to_a.product((0..7).to_a).any? do |square|
      piece = @grid.dig(*square)

      next if piece.nil? || piece.color == color

      available_attacks(square).any? do |attack_square|
        @grid.dig(*attack_square).instance_of?(King)
      end
    end
  end

  def prevents_check?(start_square, target_square)
    piece = move_piece(start_square, target_square)
    is_check = check?(piece.color)

    move_piece(target_square, start_square)
    !is_check
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
      target_square = square_from_vector(start_square, vector)

      return squares unless on_board?(target_square) && square_available?(target_square)

      squares << target_square
    end
  end

  def sliding_movements(piece, start_square)
    piece.moves.each_with_object([]) do |direction, movements|
      new_movements = squares_along_ray(start_square, direction).filter do |square|
        square_available?(square)
      end

      movements.concat(new_movements)
    end
  end

  def stepping_movements(piece, start_square)
    piece.moves.filter_map do |vector|
      target_square = square_from_vector(start_square, vector)
      target_square if on_board?(target_square) && square_available?(target_square)
    end
  end

  def sliding_attacks(piece, start_square)
    piece.attacks.each_with_object([]) do |direction, attacks|
      new_attacks = squares_along_ray(start_square, direction).filter do |square|
        found_piece = @grid.dig(*square)
        piece.enemy_of?(found_piece)
      end

      attacks.concat(new_attacks)
    end
  end

  def stepping_attacks(piece, start_square)
    piece.attacks.filter_map do |vector|
      target_square = square_from_vector(start_square, vector)
      found_piece = @grid.dig(*target_square)
      target_square if on_board?(target_square) && piece.enemy_of?(found_piece)
    end
  end

  def on_board?(square)
    row, col = square
    row.between?(0, 7) && col.between?(0, 7)
  end

  def square_available?(square)
    @grid.dig(*square).nil?
  end

  def square_from_vector(start_square, vector)
    start_square.zip(vector).map(&:sum)
  end

  def squares_along_ray(start_square, direction)
    (1..7).each_with_object([]) do |step, squares|
      target_square = square_in_direction(start_square, direction, step)
      break squares unless on_board?(target_square)

      squares << target_square

      piece = @grid.dig(*target_square)
      break squares if piece
    end
  end

  def square_in_direction(start_square, direction, step)
    vector = direction.map { |delta| delta * step }
    square_from_vector(start_square, vector)
  end
end
