# frozen_string_literal: true

require './lib/rook'

describe Rook do
  let(:movement_directions) do
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end

  describe '#to_s' do
    context 'when the rook is white' do
      subject(:white_rook) { described_class.new(:white) }

      it "returns the white rook unicode symbol (\u2656)" do
        expect(white_rook.to_s).to eq("\u2656")
      end
    end

    context 'when the rook is black' do
      subject(:black_rook) { described_class.new(:black) }

      it "returns the black rook unicode symbol (\u265C)" do
        expect(black_rook.to_s).to eq("\u265C")
      end
    end
  end

  describe '#moves' do
    subject(:rook) { described_class.new(:white) }

    it 'returns the orthogonal movement directions' do
      expect(rook.moves).to match_array(movement_directions)
    end
  end

  describe '#attacks' do
    subject(:rook) { described_class.new(:white) }

    it 'returns the orthogonal attack directions' do
      expect(rook.attacks).to match_array(movement_directions)
    end
  end
end
