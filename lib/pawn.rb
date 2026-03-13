# frozen_string_literal: true

require './lib/piece'

# The Pawn subclass manages a Pawn chess piece.
# It implements the abstract methods from the Piece superclass.
class Pawn < Piece
  def initialize(is_white)
    super
    @first_move = true
    @direction = white? ? 1 : -1
  end

  def first_move?
    @first_move
  end

  def disable_double_step
    @first_move = false
  end

  def moves
    if first_move?
      [[@direction, 0], [@direction * 2, 0]]
    else
      [[@direction, 0]]
    end
  end
end
