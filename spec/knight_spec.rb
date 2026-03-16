# frozen_string_literal: true

require './lib/knight'

describe Knight do
  let(:movement_vectors) { [[2, -1], [2, 1], [1, -2], [1, 2], [-1, -2], [-1, 2], [-2, -1], [-2, 1]] }

  describe '#to_s' do
    context 'when the knight is white' do
      subject(:white_knight) { described_class.new(true) }

      it "returns the white knight unicode symbol (\u2658)" do
        expect(white_knight.to_s).to be("\u2658")
      end
    end

    context 'when the knight is black' do
      subject(:black_knight) { described_class.new(false) }

      it "returns the black knight unicode symbol (\u265E)" do
        expect(black_knight.to_s).to be("\u265E")
      end
    end
  end

  describe '#moves' do
    subject(:knight) { described_class.new(true) }

    it 'returns the L-shaped movement vectors' do
      expect(knight.moves).to match_array(movement_vectors)
    end
  end
end
