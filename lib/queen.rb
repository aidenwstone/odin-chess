# frozen_string_literal: true

require './lib/piece'

# The Queen subclass manages a Queen chess piece.
# It implements the abstract methods from the Piece superclass.
class Queen < Piece
  def to_s
    white? ? "\u2655" : "\u265B"
  end
end
