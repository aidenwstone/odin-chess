# frozen_string_literal: true

# The Piece class serves as the superclass for more specific classes (such as Queen or Rook).
# It stores the color of the piece and provides abstract methods for subclasses to implement.
class Piece
  ORTHOGONAL_MOVES = [[0, -7], [0, -6], [0, -5], [0, -4], [0, -3], [0, -2], [0, -1],
                      [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
                      [-7, 0], [-6, 0], [-5, 0], [-4, 0], [-3, 0], [-2, 0], [-1, 0],
                      [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]]
                     .freeze

  DIAGONAL_MOVES = [[-7, 7], [-6, 6], [-5, 5], [-4, 4], [-3, 3], [-2, 2], [-1, 1],
                    [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
                    [7, 7], [6, 6], [5, 5], [4, 4], [3, 3], [2, 2], [1, 1],
                    [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]
                   .freeze

  def initialize(is_white)
    @is_white = is_white
  end

  def white?
    @is_white
  end

  def black?
    !@is_white
  end

  def moves
    raise NotImplementedError, "#{self.class} must implement #moves"
  end

  def attacks
    raise NotImplementedError, "#{self.class} must implement #attacks"
  end

  def to_s
    raise NotImplementedError, "#{self.class} must implement #to_s"
  end
end
