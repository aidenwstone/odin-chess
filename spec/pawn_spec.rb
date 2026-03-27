# frozen_string_literal: true

require './lib/pawn'

describe Pawn do
  describe '#to_s' do
    context 'when the pawn is white' do
      subject(:white_pawn) { described_class.new(:white) }

      it "returns the white pawn unicode symbol (\u2659)" do
        expect(white_pawn.to_s).to eq("\u2659")
      end
    end

    context 'when the pawn is black' do
      subject(:black_pawn) { described_class.new(:black) }

      it "returns the black pawn unicode symbol (\u265F)" do
        expect(black_pawn.to_s).to eq("\u265F")
      end
    end
  end

  describe '#disable_double_step' do
    subject(:pawn) { described_class.new(:white) }

    it 'marks the pawn as having moved' do
      pawn.disable_double_step
      expect(pawn.first_move?).to be(false)
    end
  end

  describe '#moves' do
    context 'when the pawn is white' do
      subject(:white_pawn) { described_class.new(:white) }

      it 'returns the forward and double-step movement vectors on the first move' do
        expect(white_pawn.moves).to contain_exactly([1, 0], [2, 0])
      end

      it 'returns only the single-step forward movement vector on subsequent moves' do
        white_pawn.disable_double_step
        expect(white_pawn.moves).to contain_exactly([1, 0])
      end
    end

    context 'when the pawn is black' do
      subject(:black_pawn) { described_class.new(:black) }

      it 'returns the forward and double-step movement vectors on the first move' do
        expect(black_pawn.moves).to contain_exactly([-1, 0], [-2, 0])
      end

      it 'returns only the single-step forward movement vector on subsequent moves' do
        black_pawn.disable_double_step
        expect(black_pawn.moves).to contain_exactly([-1, 0])
      end
    end
  end

  describe '#attacks' do
    context 'when the pawn is white' do
      subject(:white_pawn) { described_class.new(:white) }

      it 'returns the diagonally adjacent forward attack vectors' do
        expect(white_pawn.attacks).to contain_exactly([1, 1], [1, -1])
      end
    end

    context 'when the pawn is black' do
      subject(:black_pawn) { described_class.new(:black) }

      it 'returns the diagonally adjacent forward attack vectors' do
        expect(black_pawn.attacks).to contain_exactly([-1, 1], [-1, -1])
      end
    end
  end
end
