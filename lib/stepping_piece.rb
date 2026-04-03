# frozen_string_literal: true

require './lib/piece'

# The SteppingPiece class serves as the superclass for pieces that move by stepping (i.e. Knight and King).
class SteppingPiece < Piece
  attr_reader :movement_type

  def initialize(color)
    super
    @movement_type = :stepping
  end
end
