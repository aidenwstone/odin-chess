# frozen_string_literal: true

require './lib/piece'

# The King subclass manages a King chess piece.
# It implements the abstract methods from the Piece superclass.
class King < Piece
  POSSIBLE_MOVES = [[1, -1], [1, 0], [1, 1], [0, -1], [0, 1], [-1, -1], [-1, 0], [-1, 1]].freeze

  def to_s
    white? ? "\u2654" : "\u265A"
  end

  def moves
    POSSIBLE_MOVES
  end
end
