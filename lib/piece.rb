# frozen_string_literal: true

# The Piece class serves as the superclass for more specific classes (such as Queen or Rook).
# It stores the color of the piece and provides abstract methods for subclasses to implement.
class Piece
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
