# frozen_string_literal: true

require './lib/piece'

# The Queen subclass manages a Queen chess piece.
# It implements the abstract methods from the Piece superclass.
class Queen < Piece
  def to_s
    white? ? "\u2655" : "\u265B"
  end

  def moves
    ORTHOGONAL_MOVES + DIAGONAL_MOVES
  end

  def attacks
    ORTHOGONAL_MOVES + DIAGONAL_MOVES
  end
end
