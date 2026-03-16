# frozen_string_literal: true

require './lib/rook'

describe Rook do
  describe '#to_s' do
    context 'when the rook is white' do
      subject(:white_rook) { described_class.new(true) }

      it "returns the white rook unicode symbol (\u2656)" do
        expect(white_rook.to_s).to be("\u2656")
      end
    end

    context 'when the rook is black' do
      subject(:black_rook) { described_class.new(false) }

      it "returns the black rook unicode symbol (\u265C)" do
        expect(black_rook.to_s).to be("\u265C")
      end
    end
  end
end
