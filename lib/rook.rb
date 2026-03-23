# frozen_string_literal: true

require './lib/piece'

# The Rook subclass manages a Rook chess piece.
# It implements the abstract methods from the Piece superclass.
class Rook < Piece
  POSSIBLE_MOVES = [[0, -7], [0, -6], [0, -5], [0, -4], [0, -3], [0, -2], [0, -1],
                    [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
                    [-7, 0], [-6, 0], [-5, 0], [-4, 0], [-3, 0], [-2, 0], [-1, 0],
                    [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]]
                   .freeze

  def to_s
    white? ? "\u2656" : "\u265C"
  end

  def moves
    POSSIBLE_MOVES
  end

  def attacks
    POSSIBLE_MOVES
  end
end
