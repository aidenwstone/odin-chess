# frozen_string_literal: true

require './lib/sliding_piece'

# The Bishop subclass manages a Bishop chess piece.
# It implements the abstract methods from the Piece superclass.
class Bishop < SlidingPiece
  def to_s
    white? ? "\u2657" : "\u265D"
  end

  def moves
    DIAGONAL_DIRECTIONS
  end

  def attacks
    DIAGONAL_DIRECTIONS
  end
end
