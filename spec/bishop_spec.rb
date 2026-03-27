# frozen_string_literal: true

require './lib/bishop'

describe Bishop do
  let(:movement_vectors) do
    [[-7, 7], [-6, 6], [-5, 5], [-4, 4], [-3, 3], [-2, 2], [-1, 1],
     [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
     [7, 7], [6, 6], [5, 5], [4, 4], [3, 3], [2, 2], [1, 1],
     [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]
  end

  describe '#to_s' do
    context 'when the bishop is white' do
      subject(:white_bishop) { described_class.new(:white) }

      it "returns the white bishop unicode symbol (\u2657)" do
        expect(white_bishop.to_s).to eq("\u2657")
      end
    end

    context 'when the bishop is black' do
      subject(:black_bishop) { described_class.new(:black) }

      it "returns the black bishop unicode symbol (\u265D)" do
        expect(black_bishop.to_s).to eq("\u265D")
      end
    end
  end

  describe '#moves' do
    subject(:bishop) { described_class.new(:white) }

    it 'returns the diagonal movement vectors' do
      expect(bishop.moves).to match_array(movement_vectors)
    end
  end

  describe '#attacks' do
    subject(:bishop) { described_class.new(:white) }

    it 'returns the diagonal attack vectors' do
      expect(bishop.attacks).to match_array(movement_vectors)
    end
  end
end
