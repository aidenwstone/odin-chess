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

  describe '#remove_piece' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the specified square is occupied' do
      let(:current_piece) { Rook.new(:white) }

      before do
        board.place_piece(current_piece, 2, 6)
      end

      it 'removes the current piece' do
        board.remove_piece(2, 6)
        expect(board.grid[2][6]).to be_nil
      end

      it 'returns the removed piece' do
        return_value = board.remove_piece(2, 6)
        expect(return_value).to be(current_piece)
      end
    end

    context 'when the specified square is empty' do
      it 'raises a RuntimeError' do
        expect { board.remove_piece(3, 7) }.to raise_error(RuntimeError)
      end
    end

    context 'when the specified square is out of bounds' do
      it 'raises an ArgumentError' do
        expect { board.remove_piece(0, 8) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#move_piece' do
    subject(:board) { described_class.new(setup: :empty) }

    let(:piece) { Piece.new(:white) }

    before do
      board.place_piece(piece, 3, 5)
    end

    it 'removes the piece from the old square' do
      board.move_piece([3, 5], [3, 1])
      expect(board.grid.dig(3, 5)).to be_nil
    end

    it 'places the piece on the target square' do
      board.move_piece([3, 5], [3, 1])
      expect(board.grid.dig(3, 1)).to be(piece)
    end

    it 'returns the piece' do
      expect(board.move_piece([3, 5], [3, 1])).to be(piece)
    end
  end

  describe '#available_moves' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when a rook has clear paths' do
      let(:valid_moves) do
        [
          [4, 2], [4, 1], [4, 0],
          [5, 3], [6, 3], [7, 3],
          [4, 4], [4, 5], [4, 6], [4, 7],
          [3, 3], [2, 3], [1, 3], [0, 3]
        ]
      end

      before do
        board.place_piece(Rook.new(:white), 4, 3)
      end

      it 'returns all orthogonal squares' do
        expect(board.available_moves([4, 3])).to match_array(valid_moves)
      end
    end

    context 'when a rook has blocked paths' do
      let(:valid_moves_blocked) do
        [
          [5, 3], [6, 3], [7, 3],
          [4, 0], [4, 1], [4, 2], [4, 4]
        ]
      end

      before do
        board.place_piece(Rook.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 4, 5)
        board.place_piece(Piece.new(:white), 3, 3)
      end

      it 'returns all non-blocked orthogonal squares' do
        expect(board.available_moves([4, 3])).to match_array(valid_moves_blocked)
      end
    end

    context 'when a bishop has clear paths' do
      let(:valid_moves) do
        [
          [4, 2], [5, 1], [6, 0],
          [4, 4], [5, 5], [6, 6], [7, 7],
          [2, 2], [1, 1], [0, 0],
          [2, 4], [1, 5], [0, 6]
        ]
      end

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
      end

      it 'returns all diagonal squares' do
        expect(board.available_moves([3, 3])).to match_array(valid_moves)
      end
    end

    context 'when a bishop has blocked paths' do
      let(:valid_moves_blocked) do
        [
          [4, 2], [5, 1], [6, 0],
          [4, 4],
          [2, 2], [1, 1], [0, 0]
        ]
      end

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:white), 2, 4)
      end

      it 'returns all non-blocked diagonal squares' do
        expect(board.available_moves([3, 3])).to match_array(valid_moves_blocked)
      end
    end

    context 'when a queen has clear paths' do
      let(:valid_moves) do
        [
          [3, 2], [3, 1], [3, 0],
          [4, 3], [5, 3], [6, 3], [7, 3],
          [3, 4], [3, 5], [3, 6], [3, 7],
          [2, 3], [1, 3], [0, 3],
          [4, 2], [5, 1], [6, 0],
          [4, 4], [5, 5], [6, 6], [7, 7],
          [2, 2], [1, 1], [0, 0],
          [2, 4], [1, 5], [0, 6]
        ]
      end

      before do
        board.place_piece(Queen.new(:white), 3, 3)
      end

      it 'returns all orthogonal and diagonal squares' do
        expect(board.available_moves([3, 3])).to match_array(valid_moves)
      end
    end

    context 'when a queen has blocked paths' do
      let(:valid_moves_blocked) do
        [
          [4, 3],
          [3, 4], [3, 5], [3, 6], [3, 7],
          [2, 3], [1, 3], [0, 3],
          [4, 2], [5, 1], [6, 0],
          [4, 4],
          [2, 2], [1, 1], [0, 0]
        ]
      end

      before do
        board.place_piece(Queen.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 3, 2)
        board.place_piece(Piece.new(:white), 5, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:white), 2, 4)
      end

      it 'returns all non-blocked orthogonal and diagonal squares' do
        expect(board.available_moves([3, 3])).to match_array(valid_moves_blocked)
      end
    end

    context 'when a knight has clear squares' do
      let(:valid_moves) { [[5, 1], [6, 2], [6, 4], [5, 5], [3, 5], [2, 4], [2, 2], [3, 1]] }

      before do
        board.place_piece(Knight.new(:white), 4, 3)
      end

      it 'returns all L-shaped squares' do
        expect(board.available_moves([4, 3])).to match_array(valid_moves)
      end
    end

    context 'when a knight has blocked squares' do
      let(:valid_moves_blocked) { [[5, 1], [6, 2], [5, 5], [3, 5], [2, 4], [2, 2]] }

      before do
        board.place_piece(Knight.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 6, 4)
        board.place_piece(Piece.new(:white), 3, 1)
      end

      it 'returns all empty L-shaped squares' do
        expect(board.available_moves([4, 3])).to match_array(valid_moves_blocked)
      end
    end

    context 'when a king has clear squares' do
      let(:valid_moves) { [[4, 4], [5, 4], [5, 5], [5, 6], [4, 6], [3, 6], [3, 5], [3, 4]] }

      before do
        board.place_piece(King.new(:white), 4, 5)
      end

      it 'returns all adjacent squares' do
        expect(board.available_moves([4, 5])).to match_array(valid_moves)
      end
    end

    context 'when a king has blocked squares' do
      let(:valid_moves_blocked) { [[4, 4], [5, 5], [5, 6], [4, 6], [3, 5], [3, 4]] }

      before do
        board.place_piece(King.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 5, 4)
        board.place_piece(Piece.new(:white), 3, 6)
      end

      it 'returns all empty adjacent squares' do
        expect(board.available_moves([4, 5])).to match_array(valid_moves_blocked)
      end
    end

    context "when a pawn on it's first move has clear squares" do
      let(:valid_moves) { [[2, 1], [3, 1]] }

      before do
        board.place_piece(Pawn.new(:white), 1, 1)
      end

      it 'returns the two squares in front of the pawn' do
        expect(board.available_moves([1, 1])).to match_array(valid_moves)
      end
    end

    context "when a pawn on it's first move has blocked squares" do
      before do
        board.place_piece(Pawn.new(:white), 1, 1)
        board.place_piece(Piece.new(:black), 2, 1)
      end

      it 'returns an empty array' do
        expect(board.available_moves([1, 1])).to be_empty
      end
    end

    context 'when a pawn on a subsequent move has a clear square' do
      let(:valid_moves) { [[6, 2]] }

      before do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, 5, 2)
        pawn.disable_double_step
      end

      it 'returns the square in front of the pawn' do
        expect(board.available_moves([5, 2])).to match_array(valid_moves)
      end
    end

    context 'when a pawn on a subsequent move has a blocked square' do
      before do
        pawn = Pawn.new(:white)
        pawn.disable_double_step
        board.place_piece(pawn, 5, 2)
        board.place_piece(Piece.new(:black), 6, 2)
      end

      it 'returns an empty array' do
        expect(board.available_moves([5, 2])).to be_empty
      end
    end
  end

  describe '#available_attacks' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when a rook has available attacks' do
      let(:valid_attacks) { [[4, 1], [0, 3]] }

      before do
        board.place_piece(Rook.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 4, 1)
        board.place_piece(Piece.new(:black), 4, 0)
        board.place_piece(Piece.new(:white), 6, 3)
        board.place_piece(Piece.new(:black), 7, 3)
        board.place_piece(Piece.new(:black), 0, 3)
      end

      it 'returns all non-blocked enemy-occupied orthogonal squares' do
        expect(board.available_attacks([4, 3])).to match_array(valid_attacks)
      end
    end

    context 'when a rook has no available attacks' do
      before do
        board.place_piece(Rook.new(:white), 4, 3)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([4, 3])).to be_empty
      end
    end

    context 'when a bishop has available attacks' do
      let(:valid_attacks) { [[5, 5], [5, 1]] }

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:black), 6, 6)
        board.place_piece(Piece.new(:white), 1, 5)
        board.place_piece(Piece.new(:black), 0, 6)
        board.place_piece(Piece.new(:black), 5, 1)
      end

      it 'returns all non-blocked enemy-occupied diagonal squares' do
        expect(board.available_attacks([3, 3])).to match_array(valid_attacks)
      end
    end

    context 'when a bishop has no available attacks' do
      before do
        board.place_piece(Bishop.new(:white), 3, 3)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([3, 3])).to be_empty
      end
    end

    context 'when a queen has available attacks' do
      let(:valid_attacks) { [[3, 5], [5, 5], [5, 1]] }

      before do
        board.place_piece(Queen.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 3, 5)
        board.place_piece(Piece.new(:black), 3, 6)
        board.place_piece(Piece.new(:white), 5, 3)
        board.place_piece(Piece.new(:black), 6, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:black), 6, 6)
        board.place_piece(Piece.new(:white), 1, 5)
        board.place_piece(Piece.new(:black), 0, 6)
        board.place_piece(Piece.new(:black), 5, 1)
      end

      it 'returns all non-blocked enemy-occupied orthogonal and diagonal squares' do
        expect(board.available_attacks([3, 3])).to match_array(valid_attacks)
      end
    end

    context 'when a queen has no available attacks' do
      before do
        board.place_piece(Queen.new(:white), 3, 3)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([3, 3])).to be_empty
      end
    end

    context 'when a knight has available attacks' do
      let(:valid_attacks) { [[5, 1], [2, 2]] }

      before do
        board.place_piece(Knight.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 5, 1)
        board.place_piece(Piece.new(:white), 2, 4)
        board.place_piece(Piece.new(:black), 2, 2)
      end

      it 'returns all enemy-occupied L-shaped attack squares' do
        expect(board.available_attacks([4, 3])).to match_array(valid_attacks)
      end
    end

    context 'when a knight has no available attacks' do
      before do
        board.place_piece(Knight.new(:white), 4, 3)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([4, 3])).to be_empty
      end
    end

    context 'when a king has available attacks' do
      let(:available_attacks) { [[4, 4], [4, 6]] }

      before do
        board.place_piece(King.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 4, 4)
        board.place_piece(Piece.new(:white), 5, 6)
        board.place_piece(Piece.new(:black), 4, 6)
      end

      it 'returns all enemy-occupied adjacent squares' do
        expect(board.available_attacks([4, 5])).to match_array(available_attacks)
      end
    end

    context 'when a king has no available attacks' do
      before do
        board.place_piece(King.new(:white), 4, 5)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([4, 5])).to be_empty
      end
    end

    context 'when a pawn has available attacks' do
      let(:valid_attacks) { [[2, 0]] }

      before do
        board.place_piece(Pawn.new(:white), 1, 1)
        board.place_piece(Piece.new(:black), 2, 0)
        board.place_piece(Piece.new(:black), 2, 1)
        board.place_piece(Piece.new(:white), 2, 2)
      end

      it 'returns all enemy-occupied diagonally adjacent forward squares' do
        expect(board.available_attacks([1, 1])).to match_array(valid_attacks)
      end
    end

    context 'when a pawn has no available attacks' do
      before do
        board.place_piece(Pawn.new(:white), 1, 1)
      end

      it 'returns an empty array' do
        expect(board.available_attacks([1, 1])).to be_empty
      end
    end
  end

  describe '#check?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the king is in check' do
      before do
        board.place_piece(King.new(:black), 5, 2)
        board.place_piece(Rook.new(:white), 1, 2)
      end

      it 'returns true' do
        expect(board.check?(:black)).to be true
      end
    end

    context 'when the king is not in check' do
      before do
        board.place_piece(King.new(:black), 5, 2)
        board.place_piece(Rook.new(:black), 1, 2)
      end

      it 'returns false' do
        expect(board.check?(:black)).to be false
      end
    end
  end

  describe '#prevents_check?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when a move will cause the king to be in check' do
      before do
        board.place_piece(King.new(:black), 5, 2)
        board.place_piece(Rook.new(:black), 3, 2)
        board.place_piece(Rook.new(:white), 1, 2)
      end

      it 'returns false' do
        expect(board.prevents_check?([3, 2], [3, 4])).to be false
      end
    end

    context 'when a move will not cause the king to be in check' do
      before do
        board.place_piece(King.new(:black), 5, 2)
        board.place_piece(Rook.new(:black), 3, 2)
        board.place_piece(Rook.new(:white), 1, 2)
      end

      it 'returns true' do
        expect(board.prevents_check?([3, 2], [2, 2])).to be true
      end
    end
  end

  describe '#legal_moves' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when some moves by a piece can get the king out of check' do
      let(:legal_moves) do
        {
          [2, 2] => :attack,
          [2, 4] => :move,
          [2, 6] => :move
        }
      end

      before do
        board.place_piece(King.new(:white), 2, 7)
        board.place_piece(Rook.new(:black), 2, 2)
        board.place_piece(Queen.new(:white), 4, 4)
      end

      it 'returns only moves and attacks that will get the king out of check' do
        expect(board.legal_moves([4, 4])).to match(legal_moves)
      end
    end

    context 'when some moves by a piece would leave the king in check' do
      let(:legal_moves) do
        {
          [2, 4] => :move,
          [3, 4] => :move,
          [4, 4] => :move,
          [5, 4] => :move,
          [6, 4] => :move,
          [7, 4] => :attack
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:black), 7, 4)
        board.place_piece(Rook.new(:white), 1, 4)
      end

      it 'returns only moves and attacks that will not leave the king in check' do
        expect(board.legal_moves([1, 4])).to match(legal_moves)
      end
    end

    context 'when any move by a piece would leave the king in check' do
      before do
        board.place_piece(King.new(:white), 3, 4)
        board.place_piece(Bishop.new(:black), 6, 1)
        board.place_piece(Rook.new(:white), 4, 3)
      end

      it 'returns an empty hash' do
        expect(board.legal_moves([4, 3])).to be_empty
      end
    end

    context 'when some moves by the king would cause check' do
      let(:legal_moves) do
        {
          [4, 1] => :move,
          [3, 3] => :attack,
          [2, 2] => :move,
          [2, 1] => :move
        }
      end

      before do
        board.place_piece(King.new(:white), 3, 2)
        board.place_piece(Bishop.new(:black), 5, 3)
        board.place_piece(Rook.new(:black), 3, 3)
      end

      it 'returns only moves and attacks that will not cause check' do
        expect(board.legal_moves([3, 2])).to match(legal_moves)
      end
    end
  end
end
