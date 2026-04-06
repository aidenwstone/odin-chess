# frozen_string_literal: true

# The Piece class serves as the superclass for the SteppingPiece and SlidingPiece classes.
# It stores the color of the piece and provides abstract methods for subclasses to implement.
class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def enemy_of?(piece)
    return false unless piece

    @color != piece.color
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
