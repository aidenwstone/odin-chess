# frozen_string_literal: true

require './lib/board'

describe Board do
  describe '#place_piece' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the specified square is empty' do
      let(:new_piece) { Rook.new(:white) }

      it 'places the new piece on the empty square' do
        board.place_piece(new_piece, 3, 4)
        expect(board.grid[3][4]).to be(new_piece)
      end
    end

    context 'when the specified square is occupied' do
      let(:old_piece) { Bishop.new(:black) }
      let(:new_piece) { Rook.new(:white) }

      before do
        board.place_piece(old_piece, 6, 3)
      end

      it 'overrides the current piece with the new one' do
        board.place_piece(new_piece, 6, 3)
        expect(board.grid[6][3]).to be(new_piece)
      end
    end

    context 'when the specified square is out of bounds' do
      let(:new_piece) { Rook.new(:white) }

      it 'raises an ArgumentError' do
        expect { board.place_piece(new_piece, 8, 0) }.to raise_error(ArgumentError)
      end
    end
  end
end
