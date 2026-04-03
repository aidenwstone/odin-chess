# frozen_string_literal: true

require './lib/sliding_piece'

# The Queen subclass manages a Queen chess piece.
# It implements the abstract methods from the Piece superclass.
class Queen < SlidingPiece
  def to_s
    white? ? "\u2655" : "\u265B"
  end

  def moves
    ORTHOGONAL_DIRECTIONS + DIAGONAL_DIRECTIONS
  end

  def attacks
    ORTHOGONAL_DIRECTIONS + DIAGONAL_DIRECTIONS
  end
end
