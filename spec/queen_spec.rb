# frozen_string_literal: true

require './lib/queen'

describe Queen do
  let(:movement_directions) do
    [
      [1, 0], [0, 1], [-1, 0], [0, -1],
      [1, -1], [1, 1], [-1, 1], [-1, -1]
    ]
  end

  describe '#to_s' do
    context 'when the queen is white' do
      subject(:white_queen) { described_class.new(:white) }

      it "returns a white queen unicode symbol (\u2655)" do
        expect(white_queen.to_s).to eq("\u2655")
      end
    end

    context 'when the queen is black' do
      subject(:black_queen) { described_class.new(:black) }

      it "returns a black queen unicode symbol (\u265B)" do
        expect(black_queen.to_s).to eq("\u265B")
      end
    end
  end

  describe '#moves' do
    subject(:queen) { described_class.new(:white) }

    it 'returns the orthogonal and diagonal movement directions' do
      expect(queen.moves).to match_array(movement_directions)
    end
  end

  describe '#attacks' do
    subject(:queen) { described_class.new(:white) }

    it 'returns the orthogonal and diagonal attack directions' do
      expect(queen.attacks).to match_array(movement_directions)
    end
  end
end
