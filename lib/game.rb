# frozen_string_literal: true

require './lib/board'

# The Game class manages a game of chess, keeping track of the current player, asking for input,
# and announcing a winner. It also handles the saving/loading of games.
class Game
  attr_reader :board, :current_player

  def initialize
    @board = Board.new
    @current_player = :white
  end
end
