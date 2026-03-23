# frozen_string_literal: true

require './lib/piece'

# The Rook subclass manages a Rook chess piece.
# It implements the abstract methods from the Piece superclass.
class Rook < Piece
  def to_s
    white? ? "\u2656" : "\u265C"
  end

  def moves
    ORTHOGONAL_MOVES
  end

  def attacks
    ORTHOGONAL_MOVES
  end
end
