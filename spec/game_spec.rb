# frozen_string_literal: true

require './lib/game'

describe Game do
  describe '#switch_player' do
    subject(:game) { described_class.new }

    context 'when white is the current player' do
      it 'changes the current player to black' do
        expect { game.switch_player }.to change(game, :current_player).from(:white).to(:black)
      end
    end

    context 'when black is the current player' do
      before do
        game.switch_player
      end

      it 'changes the current player to white' do
        expect { game.switch_player }.to change(game, :current_player).from(:black).to(:white)
      end
    end
  end
end
