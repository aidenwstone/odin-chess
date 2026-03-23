# frozen_string_literal: true

require './lib/piece'

# The Bishop subclass manages a Bishop chess piece.
# It implements the abstract methods from the Piece superclass.
class Bishop < Piece
  AVAILABLE_MOVES = [[-7, 7], [-6, 6], [-5, 5], [-4, 4], [-3, 3], [-2, 2], [-1, 1],
                     [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
                     [7, 7], [6, 6], [5, 5], [4, 4], [3, 3], [2, 2], [1, 1],
                     [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]
                    .freeze

  def to_s
    white? ? "\u2657" : "\u265D"
  end

  def moves
    AVAILABLE_MOVES
  end

  def attacks
    AVAILABLE_MOVES
  end
end
