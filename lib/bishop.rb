# frozen_string_literal: true

require './lib/piece'

# The Bishop subclass manages a Bishop chess piece.
# It implements the abstract methods from the Piece superclass.
class Bishop < Piece
  def to_s
    white? ? "\u2657" : "\u265D"
  end
end
