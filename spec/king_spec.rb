# frozen_string_literal: true

require './lib/king'

describe King do
  let(:movement_vectors) { [[1, -1], [1, 0], [1, 1], [0, -1], [0, 1], [-1, -1], [-1, 0], [-1, 1]] }

  describe '#to_s' do
    context 'when the king is white' do
      subject(:white_king) { described_class.new(true) }

      it 'returns the white king unicode symbol' do
        expect(white_king.to_s).to be("\u2654")
      end
    end

    context 'when the king is black' do
      subject(:black_king) { described_class.new(false) }

      it 'returns the black king unicode symbol' do
        expect(black_king.to_s).to be("\u265A")
      end
    end
  end

  describe '#moves' do
    subject(:king) { described_class.new(true) }

    it 'returns the movement vectors adjacent to the king' do
      expect(king.moves).to match_array(movement_vectors)
    end
  end

  describe '#attacks' do
    subject(:king) { described_class.new(true) }

    it 'returns the attack vectors adjacent to the king' do
      expect(king.attacks).to match_array(movement_vectors)
    end
  end
end
