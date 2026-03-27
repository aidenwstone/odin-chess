# frozen_string_literal: true

require './lib/rook'

describe Rook do
  let(:movement_vectors) do
    [[0, -7], [0, -6], [0, -5], [0, -4], [0, -3], [0, -2], [0, -1],
     [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
     [-7, 0], [-6, 0], [-5, 0], [-4, 0], [-3, 0], [-2, 0], [-1, 0],
     [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0]]
  end

  describe '#to_s' do
    context 'when the rook is white' do
      subject(:white_rook) { described_class.new(true) }

      it "returns the white rook unicode symbol (\u2656)" do
        expect(white_rook.to_s).to eq("\u2656")
      end
    end

    context 'when the rook is black' do
      subject(:black_rook) { described_class.new(false) }

      it "returns the black rook unicode symbol (\u265C)" do
        expect(black_rook.to_s).to eq("\u265C")
      end
    end
  end

  describe '#moves' do
    subject(:rook) { described_class.new(true) }

    it 'returns the orthogonal movement vectors' do
      expect(rook.moves).to match_array(movement_vectors)
    end
  end

  describe '#attacks' do
    subject(:rook) { described_class.new(true) }

    it 'returns the orthogonal attack vectors' do
      expect(rook.attacks).to match_array(movement_vectors)
    end
  end
end
