# frozen_string_literal: true

require './lib/piece'

# The Pawn subclass manages a Pawn chess piece.
# It implements the abstract methods from the Piece superclass.
class Pawn < Piece
  def initialize(is_white)
    super
    @first_move = true
  end

  def first_move?
    @first_move
  end
end
