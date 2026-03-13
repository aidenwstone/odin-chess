# frozen_string_literal: true

require './lib/pawn'

describe Pawn do
  describe '#disable_double_step' do
    subject(:pawn) { described_class.new(true) }

    it 'marks the pawn as having moved' do
      pawn.disable_double_step
      expect(pawn.first_move?).to be(false)
    end
  end
end
