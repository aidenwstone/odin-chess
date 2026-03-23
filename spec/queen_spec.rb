# frozen_string_literal: true

require './lib/queen'

describe Queen do
  describe '#to_s' do
    context 'when the queen is white' do
      subject(:white_queen) { described_class.new(true) }

      it "returns a white queen unicode symbol (\u2655)" do
        expect(white_queen.to_s).to be("\u2655")
      end
    end

    context 'when the queen is black' do
      subject(:black_queen) { described_class.new(false) }

      it "returns a black queen unicode symbol (\u265B)" do
        expect(black_queen.to_s).to be("\u265B")
      end
    end
  end
end
