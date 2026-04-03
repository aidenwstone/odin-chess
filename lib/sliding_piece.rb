# frozen_string_literal: true

require './lib/piece'

# The SlidingPiece class serves as the superclass for pieces that move by sliding (i.e. Rook and Bishop).
class SlidingPiece < Piece
  ORTHOGONAL_DIRECTIONS = [[1, 0], [0, 1], [-1, 0], [0, -1]].freeze
  DIAGONAL_DIRECTIONS = [[1, -1], [1, 1], [-1, 1], [-1, -1]].freeze

  attr_reader :movement_type

  def initialize(color)
    super
    @movement_type = :sliding
  end
end
