# frozen_string_literal: true

require './lib/piece'

describe Piece do
  describe '#enemy_of?' do
    subject(:hero_piece) { described_class.new(:white) }

    context 'when a black piece is checked against a white piece' do
      let(:black_piece) { described_class.new(:black) }

      it 'returns true' do
        expect(hero_piece.enemy_of?(black_piece)).to be true
      end
    end

    context 'when a white piece is checked against a white piece' do
      let(:white_piece) { described_class.new(:white) }

      it 'returns false' do
        expect(hero_piece.enemy_of?(white_piece)).to be false
      end
    end

    context 'when nil is checked against a piece' do
      it 'returns false' do
        expect(hero_piece.enemy_of?(nil)).to be false
      end
    end
  end
end
