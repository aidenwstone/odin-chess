# frozen_string_literal: true

require './lib/queen'

describe Queen do
  let(:movement_vectors) do
    [[0, -7], [0, -6], [0, -5], [0, -4], [0, -3], [0, -2], [0, -1],
     [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
     [-7, 0], [-6, 0], [-5, 0], [-4, 0], [-3, 0], [-2, 0], [-1, 0],
     [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
     [-7, 7], [-6, 6], [-5, 5], [-4, 4], [-3, 3], [-2, 2], [-1, 1],
     [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
     [7, 7], [6, 6], [5, 5], [4, 4], [3, 3], [2, 2], [1, 1],
     [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7]]
  end

  describe '#to_s' do
    context 'when the queen is white' do
      subject(:white_queen) { described_class.new(true) }

      it "returns a white queen unicode symbol (\u2655)" do
        expect(white_queen.to_s).to eq("\u2655")
      end
    end

    context 'when the queen is black' do
      subject(:black_queen) { described_class.new(false) }

      it "returns a black queen unicode symbol (\u265B)" do
        expect(black_queen.to_s).to eq("\u265B")
      end
    end
  end

  describe '#moves' do
    subject(:queen) { described_class.new(true) }

    it 'returns the orthogonal and diagonal movement vectors' do
      expect(queen.moves).to match_array(movement_vectors)
    end
  end

  describe '#attacks' do
    subject(:queen) { described_class.new(true) }

    it 'returns the orthogonal and diagonal attack vectors' do
      expect(queen.attacks).to match_array(movement_vectors)
    end
  end
end
