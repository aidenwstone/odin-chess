# frozen_string_literal: true

require './lib/king'

describe King do
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
end
