# frozen_string_literal: true

require './lib/piece'

# The Knight subclass manages a Knight chess piece.
# It implements the abstract methods from the Piece superclass.
class Knight < Piece
  POSSIBLE_MOVES = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]].freeze

  def to_s
    white? ? "\u2658" : "\u265E"
  end

  def moves
    POSSIBLE_MOVES
  end

  def attacks
    POSSIBLE_MOVES
  end
end
