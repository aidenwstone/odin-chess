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
  ALL_SQUARES = (0..7).to_a.product((0..7).to_a).freeze
  CASTLING_SQUARES = {
    white: {
      king_square: [0, 4],
      kingside: {
        rook_square: [0, 7],
        between_king_and_rook: [[0, 5], [0, 6]],
        king_path: [[0, 5], [0, 6]]
      },
      queenside: {
        rook_square: [0, 0],
        between_king_and_rook: [[0, 3], [0, 2], [0, 1]],
        king_path: [[0, 3], [0, 2]]
      }
    },
    black: {
      king_square: [7, 4],
      kingside: {
        rook_square: [7, 7],
        between_king_and_rook: [[7, 5], [7, 6]],
        king_path: [[7, 5], [7, 6]]
      },
      queenside: {
        rook_square: [7, 0],
        between_king_and_rook: [[7, 3], [7, 2], [7, 1]],
        king_path: [[7, 3], [7, 2]]
      }
    }
  }.freeze
  EMPTY_SUMMARY = {
    white: { King: 0, Queen: 0, Rook: 0, Bishop: { light: 0, dark: 0 }, Knight: 0, Pawn: 0 },
    black: { King: 0, Queen: 0, Rook: 0, Bishop: { light: 0, dark: 0 }, Knight: 0, Pawn: 0 }
  }.freeze

  attr_reader :grid

  def initialize(setup: :standard)
    @grid = Array.new(8) { Array.new(8) }
    @board_state_log = []

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

  def move_piece(start_square, target_square, log_move: true)
    piece = remove_piece(*start_square)
    place_piece(piece, *target_square)

    if log_move
      @board_state_log.push(@grid.hash)
      piece.after_move
    end

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

  def piece_on(square)
    @grid.dig(*square)
  end

  def available_moves(start_square)
    piece = piece_on(start_square)

    return if piece.nil?

    if piece.instance_of?(Pawn)
      pawn_movements(piece, start_square)
    elsif piece.movement_type == :sliding
      sliding_movements(piece, start_square)
    elsif piece.movement_type == :stepping
      stepping_movements(piece, start_square)
    end
  end

  def available_attacks(start_square)
    piece = piece_on(start_square)

    return if piece.nil?

    if piece.movement_type == :sliding
      sliding_attacks(piece, start_square)
    elsif piece.movement_type == :stepping
      stepping_attacks(piece, start_square)
    end
  end

  def available_castling_moves(color)
    row = color == :white ? 0 : 7
    moves = { kingside: [row, 6], queenside: [row, 2] }

    moves.filter_map do |side, square|
      square if can_castle?(color, side)
    end
  end

  def legal_moves(start_square)
    piece = piece_on(start_square)
    moves = available_moves(start_square).to_h { |square| [square, :move] }
    attacks = available_attacks(start_square).to_h { |square| [square, :attack] }

    all_moves = moves.merge(attacks).filter do |target_square|
      prevents_check?(start_square, target_square)
    end

    return all_moves unless piece.instance_of?(King)

    castling_moves = available_castling_moves(piece.color).to_h { |square| [square, :castling] }
    all_moves.merge(castling_moves)
  end

  def should_promote?(square)
    row = square[0]
    piece = piece_on(square)
    return false unless piece.instance_of?(Pawn)

    (piece.black? && row.zero?) || (piece.white? && row == 7)
  end

  def check?(color)
    enemy_color = color == :white ? :black : :white

    player_squares(enemy_color).any? do |square|
      available_attacks(square).any? do |target_square|
        piece_on(target_square).instance_of?(King)
      end
    end
  end

  def prevents_check?(start_square, target_square)
    grid_backup = @grid.map(&:dup)
    piece = move_piece(start_square, target_square, log_move: false)
    is_check = check?(piece.color)

    @grid = grid_backup
    !is_check
  end

  def checkmate?(color)
    return false unless check?(color)

    player_squares(color).none? { |square| legal_moves(square).any? }
  end

  def stalemate?(color)
    return false if check?(color)

    player_squares(color).all? { |square| legal_moves(square).empty? }
  end

  def threefold_repetition?
    @board_state_log.count(@grid.hash) >= 3
  end

  def insufficient_material?
    material = material_summary

    !(any_heavy_piece_or_pawn?(material) || multiple_minor_pieces?(material) || bishops_on_opposite_colors?(material))
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
    row = row.reverse if perspective == :black
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
        found_piece = piece_on(square)
        piece.enemy_of?(found_piece)
      end

      attacks.concat(new_attacks)
    end
  end

  def stepping_attacks(piece, start_square)
    piece.attacks.filter_map do |vector|
      target_square = square_from_vector(start_square, vector)
      found_piece = piece_on(target_square)
      target_square if on_board?(target_square) && piece.enemy_of?(found_piece)
    end
  end

  def on_board?(square)
    row, col = square
    row.between?(0, 7) && col.between?(0, 7)
  end

  def square_available?(square)
    piece_on(square).nil?
  end

  def square_from_vector(start_square, vector)
    start_square.zip(vector).map(&:sum)
  end

  def squares_along_ray(start_square, direction)
    (1..7).each_with_object([]) do |step, squares|
      target_square = square_in_direction(start_square, direction, step)
      break squares unless on_board?(target_square)

      squares << target_square

      piece = piece_on(target_square)
      break squares if piece
    end
  end

  def square_in_direction(start_square, direction, step)
    vector = direction.map { |delta| delta * step }
    square_from_vector(start_square, vector)
  end

  def can_castle?(color, side)
    king_and_rook_unmoved?(color, side) &&
      !check?(color) &&
      clear_between_king_and_rook?(color, side) &&
      castling_path_safe?(color, side)
  end

  def king_and_rook_unmoved?(color, side)
    king_square = CASTLING_SQUARES.dig(color, :king_square)
    rook_square = CASTLING_SQUARES.dig(color, side, :rook_square)
    castling_pieces = [king_square, rook_square].map { |square| piece_on(square) }

    true unless castling_pieces.any?(&:nil?) || castling_pieces.any?(&:moved?)
  end

  def clear_between_king_and_rook?(color, side)
    squares_between = CASTLING_SQUARES.dig(color, side, :between_king_and_rook)

    squares_between.all? { |square| square_available?(square) }
  end

  def castling_path_safe?(color, side)
    king_square = CASTLING_SQUARES.dig(color, :king_square)
    path_squares = CASTLING_SQUARES.dig(color, side, :king_path)

    path_squares.all? { |square| prevents_check?(king_square, square) }
  end

  def player_squares(color)
    ALL_SQUARES.filter do |square|
      piece = piece_on(square)
      piece && piece.color == color
    end
  end

  def material_summary # rubocop:disable Metrics/AbcSize
    occupied_squares = ALL_SQUARES.filter { |square| piece_on(square) }

    occupied_squares.each_with_object(hash_deep_dup(EMPTY_SUMMARY)) do |square, summary|
      piece = piece_on(square)

      class_symbol = piece.class.name.to_sym

      if piece.instance_of?(Bishop)
        summary[piece.color][class_symbol][square_color(*square)] += 1
      else
        summary[piece.color][class_symbol] += 1
      end
    end
  end

  def hash_deep_dup(hash)
    Marshal.load(Marshal.dump(hash))
  end

  def square_color(row, column)
    if (row.even? && column.odd?) || (row.odd? && column.even?)
      :light
    else
      :dark
    end
  end

  def any_heavy_piece_or_pawn?(material)
    pawn_count = material.dig(:white, :Pawn) + material.dig(:black, :Pawn)
    rook_count = material.dig(:white, :Rook) + material.dig(:black, :Rook)
    queen_count = material.dig(:white, :Queen) + material.dig(:black, :Queen)

    pawn_count.positive? || rook_count.positive? || queen_count.positive?
  end

  def multiple_minor_pieces?(material)
    white_minor_piece_count = material.dig(:white, :Bishop).values.sum + material.dig(:white, :Knight)
    black_minor_piece_count = material.dig(:black, :Bishop).values.sum + material.dig(:black, :Knight)

    white_minor_piece_count >= 2 || black_minor_piece_count >= 2
  end

  def bishops_on_opposite_colors?(material)
    light_square_bishop_count = material.dig(:white, :Bishop, :light) + material.dig(:black, :Bishop, :light)
    dark_square_bishop_count = material.dig(:white, :Bishop, :dark) + material.dig(:black, :Bishop, :dark)

    light_square_bishop_count >= 1 && dark_square_bishop_count >= 1
  end
end
