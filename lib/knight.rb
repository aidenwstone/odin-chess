# frozen_string_literal: true

require './lib/piece'

# The Knight subclass manages a Knight chess piece.
# It implements the abstract methods from the Piece superclass.
class Knight < Piece
  def to_s
    white? ? "\u2658" : "\u265E"
  end
end
