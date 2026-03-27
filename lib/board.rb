# frozen_string_literal: true

require './lib/rook'
require './lib/knight'
require './lib/bishop'
require './lib/queen'
require './lib/king'
require './lib/pawn'

# The Board class manages the state of the chessboard, keeping track of where pieces are as well as providing
# information such as whether or not a given move is legal.
class Board
  BACK_RANK = %i[rook knight bishop queen king bishop knight rook].freeze

  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }

    # Place pieces in the back rank for each player
    @grid[0] = BACK_RANK.map { |type| build_piece(type, :white) }
    @grid[7] = BACK_RANK.map { |type| build_piece(type, :black) }

    # Place Pawns for each player
    @grid[1] = Array.new(8) { build_piece(:pawn, :white) }
    @grid[6] = Array.new(8) { build_piece(:pawn, :black) }
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
end
