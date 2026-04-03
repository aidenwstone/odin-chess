# frozen_string_literal: true

require './lib/sliding_piece'

# The Rook subclass manages a Rook chess piece.
# It implements the abstract methods from the Piece superclass.
class Rook < SlidingPiece
  def to_s
    white? ? "\u2656" : "\u265C"
  end

  def moves
    ORTHOGONAL_DIRECTIONS
  end

  def attacks
    ORTHOGONAL_DIRECTIONS
  end
end
