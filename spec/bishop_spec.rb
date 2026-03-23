# frozen_string_literal: true

require './lib/bishop'

describe Bishop do
  describe '#to_s' do
    context 'when the bishop is white' do
      subject(:white_bishop) { described_class.new(true) }

      it "returns the white bishop unicode symbol (\u2657)" do
        expect(white_bishop.to_s).to be("\u2657")
      end
    end

    context 'when the bishop is black' do
      subject(:black_bishop) { described_class.new(false) }

      it "returns the black bishop unicode symbol (\u265D)" do
        expect(black_bishop.to_s).to be("\u265D")
      end
    end
  end
end
