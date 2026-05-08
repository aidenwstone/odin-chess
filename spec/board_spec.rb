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
      allow(piece).to receive(:after_move)
    end

    it 'removes the piece from the old square' do
      board.move_piece([3, 5], [3, 1])
      expect(board.grid.dig(3, 5)).to be_nil
    end

    it 'places the piece on the target square' do
      board.move_piece([3, 5], [3, 1])
      expect(board.grid.dig(3, 1)).to be(piece)
    end

    it 'calls #after_move on the piece' do
      board.move_piece([3, 5], [3, 1])
      expect(piece).to have_received(:after_move)
    end

    it 'returns the piece' do
      expect(board.move_piece([3, 5], [3, 1])).to be(piece)
    end

    context 'with a non-pawn piece' do
      before do
        allow(board).to receive(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end

      it 'does not call #activate_en_passant' do
        board.move_piece([3, 5], [3, 1])
        expect(board).not_to have_received(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end
    end

    context 'with a pawn piece on its first move' do
      let(:pawn) { Pawn.new(:white) }

      before do
        board.place_piece(pawn, 1, 3)
        allow(board).to receive(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end

      it 'calls #activate_en_passant' do
        board.move_piece([1, 3], [3, 3])
        expect(board).to have_received(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end
    end

    context 'with a pawn piece on a subsequent move' do
      let(:pawn) { Pawn.new(:white) }

      before do
        board.place_piece(pawn, 2, 3)
        pawn.disable_double_step
        allow(board).to receive(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end

      it 'does not call #activate_en_passant' do
        board.move_piece([2, 3], [3, 3])
        expect(board).not_to have_received(:activate_en_passant) # rubocop:disable RSpec/SubjectStub
      end
    end
  end

  describe '#castle' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when castling kingside' do
      let(:white_king) { King.new(:white) }
      let(:white_rook) { Rook.new(:white) }

      before do
        board.place_piece(white_king, 0, 4)
        board.place_piece(white_rook, 0, 7)
      end

      it 'removes the king from the old square' do
        board.castle(:white, :kingside)
        expect(board.piece_on([0, 4])).to be_nil
      end

      it 'moves the king two squares to the right' do
        board.castle(:white, :kingside)
        expect(board.piece_on([0, 6])).to be(white_king)
      end

      it 'removes the rook from the old square' do
        board.castle(:white, :kingside)
        expect(board.piece_on([0, 7])).to be_nil
      end

      it 'moves the rook onto the square the king passed over' do
        board.castle(:white, :kingside)
        expect(board.piece_on([0, 5])).to be(white_rook)
      end
    end

    context 'when castling queenside' do
      let(:black_king) { King.new(:black) }
      let(:black_rook) { Rook.new(:black) }

      before do
        board.place_piece(black_king, 7, 4)
        board.place_piece(black_rook, 7, 0)
      end

      it 'removes the king from the old square' do
        board.castle(:black, :queenside)
        expect(board.piece_on([7, 4])).to be_nil
      end

      it 'moves the king two squares to the right' do
        board.castle(:black, :queenside)
        expect(board.piece_on([7, 2])).to be(black_king)
      end

      it 'removes the rook from the old square' do
        board.castle(:black, :queenside)
        expect(board.piece_on([7, 0])).to be_nil
      end

      it 'moves the rook onto the square the king passed over' do
        board.castle(:black, :queenside)
        expect(board.piece_on([7, 3])).to be(black_rook)
      end
    end
  end

  describe '#piece_on' do
    subject(:board) { described_class.new(setup: :empty) }

    let(:piece) { Piece.new(:white) }

    context 'when an occupied square is chosen' do
      before do
        board.place_piece(piece, 1, 0)
      end

      it 'returns the piece' do
        expect(board.piece_on([1, 0])).to be(piece)
      end
    end

    context 'when an empty square is chosen' do
      it 'returns nil' do
        expect(board.piece_on([1, 0])).to be_nil
      end
    end
  end

  describe '#castling_side' do
    subject(:board) { described_class.new }

    context 'when given a kingside castling square' do
      let(:kingside_square) { [0, 6] }

      it 'returns :kingside' do
        expect(board.castling_side(kingside_square)).to be(:kingside)
      end
    end

    context 'when given a queenside castling square' do
      let(:queenside_square) { [7, 2] }

      it 'returns :queenside' do
        expect(board.castling_side(queenside_square)).to be(:queenside)
      end
    end
  end

  describe '#available_moves' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when a rook has clear paths' do
      let(:valid_moves) do
        {
          [4, 2] => :move, [4, 1] => :move, [4, 0] => :move,
          [5, 3] => :move, [6, 3] => :move, [7, 3] => :move,
          [4, 4] => :move, [4, 5] => :move, [4, 6] => :move, [4, 7] => :move,
          [3, 3] => :move, [2, 3] => :move, [1, 3] => :move, [0, 3] => :move
        }
      end

      before do
        board.place_piece(Rook.new(:white), 4, 3)
      end

      it 'returns all orthogonal squares' do
        expect(board.available_moves([4, 3])).to match(valid_moves)
      end
    end

    context 'when a rook has blocked paths' do
      let(:valid_moves_blocked) do
        {
          [5, 3] => :move, [6, 3] => :move, [7, 3] => :move,
          [4, 0] => :move, [4, 1] => :move, [4, 2] => :move, [4, 4] => :move
        }
      end

      before do
        board.place_piece(Rook.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 4, 5)
        board.place_piece(Piece.new(:white), 3, 3)
      end

      it 'returns all non-blocked orthogonal squares' do
        expect(board.available_moves([4, 3])).to match(valid_moves_blocked)
      end
    end

    context 'when a bishop has clear paths' do
      let(:valid_moves) do
        {
          [4, 2] => :move, [5, 1] => :move, [6, 0] => :move,
          [4, 4] => :move, [5, 5] => :move, [6, 6] => :move, [7, 7] => :move,
          [2, 2] => :move, [1, 1] => :move, [0, 0] => :move,
          [2, 4] => :move, [1, 5] => :move, [0, 6] => :move
        }
      end

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
      end

      it 'returns all diagonal squares' do
        expect(board.available_moves([3, 3])).to match(valid_moves)
      end
    end

    context 'when a bishop has blocked paths' do
      let(:valid_moves_blocked) do
        {
          [4, 2] => :move, [5, 1] => :move, [6, 0] => :move,
          [4, 4] => :move,
          [2, 2] => :move, [1, 1] => :move, [0, 0] => :move
        }
      end

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:white), 2, 4)
      end

      it 'returns all non-blocked diagonal squares' do
        expect(board.available_moves([3, 3])).to match(valid_moves_blocked)
      end
    end

    context 'when a queen has clear paths' do
      let(:valid_moves) do
        {
          [3, 2] => :move, [3, 1] => :move, [3, 0] => :move,
          [4, 3] => :move, [5, 3] => :move, [6, 3] => :move, [7, 3] => :move,
          [3, 4] => :move, [3, 5] => :move, [3, 6] => :move, [3, 7] => :move,
          [2, 3] => :move, [1, 3] => :move, [0, 3] => :move,
          [4, 2] => :move, [5, 1] => :move, [6, 0] => :move,
          [4, 4] => :move, [5, 5] => :move, [6, 6] => :move, [7, 7] => :move,
          [2, 2] => :move, [1, 1] => :move, [0, 0] => :move,
          [2, 4] => :move, [1, 5] => :move, [0, 6] => :move
        }
      end

      before do
        board.place_piece(Queen.new(:white), 3, 3)
      end

      it 'returns all orthogonal and diagonal squares' do
        expect(board.available_moves([3, 3])).to match(valid_moves)
      end
    end

    context 'when a queen has blocked paths' do
      let(:valid_moves_blocked) do
        {
          [4, 3] => :move,
          [3, 4] => :move, [3, 5] => :move, [3, 6] => :move, [3, 7] => :move,
          [2, 3] => :move, [1, 3] => :move, [0, 3] => :move,
          [4, 2] => :move, [5, 1] => :move, [6, 0] => :move,
          [4, 4] => :move,
          [2, 2] => :move, [1, 1] => :move, [0, 0] => :move
        }
      end

      before do
        board.place_piece(Queen.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 3, 2)
        board.place_piece(Piece.new(:white), 5, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:white), 2, 4)
      end

      it 'returns all non-blocked orthogonal and diagonal squares' do
        expect(board.available_moves([3, 3])).to match(valid_moves_blocked)
      end
    end

    context 'when a knight has clear squares' do
      let(:valid_moves) do
        {
          [5, 1] => :move, [6, 2] => :move, [6, 4] => :move, [5, 5] => :move,
          [3, 5] => :move, [2, 4] => :move, [2, 2] => :move, [3, 1] => :move
        }
      end

      before do
        board.place_piece(Knight.new(:white), 4, 3)
      end

      it 'returns all L-shaped squares' do
        expect(board.available_moves([4, 3])).to match(valid_moves)
      end
    end

    context 'when a knight has blocked squares' do
      let(:valid_moves_blocked) do
        {
          [5, 1] => :move, [6, 2] => :move, [5, 5] => :move,
          [3, 5] => :move, [2, 4] => :move, [2, 2] => :move
        }
      end

      before do
        board.place_piece(Knight.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 6, 4)
        board.place_piece(Piece.new(:white), 3, 1)
      end

      it 'returns all empty L-shaped squares' do
        expect(board.available_moves([4, 3])).to match(valid_moves_blocked)
      end
    end

    context 'when a king has clear squares' do
      let(:valid_moves) do
        {
          [4, 4] => :move, [5, 4] => :move, [5, 5] => :move, [5, 6] => :move,
          [4, 6] => :move, [3, 6] => :move, [3, 5] => :move, [3, 4] => :move
        }
      end

      before do
        board.place_piece(King.new(:white), 4, 5)
      end

      it 'returns all adjacent squares' do
        expect(board.available_moves([4, 5])).to match(valid_moves)
      end
    end

    context 'when a king has blocked squares' do
      let(:valid_moves_blocked) do
        {
          [4, 4] => :move, [5, 5] => :move, [5, 6] => :move,
          [4, 6] => :move, [3, 5] => :move, [3, 4] => :move
        }
      end

      before do
        board.place_piece(King.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 5, 4)
        board.place_piece(Piece.new(:white), 3, 6)
      end

      it 'returns all empty adjacent squares' do
        expect(board.available_moves([4, 5])).to match(valid_moves_blocked)
      end
    end

    context 'when a pawn on its first move has clear squares' do
      let(:valid_moves) do
        {
          [2, 1] => :move,
          [3, 1] => :move
        }
      end

      before do
        board.place_piece(Pawn.new(:white), 1, 1)
      end

      it 'returns the two squares in front of the pawn' do
        expect(board.available_moves([1, 1])).to match(valid_moves)
      end
    end

    context 'when a pawn on its first move has blocked squares' do
      before do
        board.place_piece(Pawn.new(:white), 1, 1)
        board.place_piece(Piece.new(:black), 2, 1)
      end

      it 'return an empty hash' do
        expect(board.available_moves([1, 1])).to be_empty
      end
    end

    context 'when a pawn on a subsequent move has a clear square' do
      let(:valid_moves) do
        {
          [6, 2] => :move
        }
      end

      before do
        pawn = Pawn.new(:white)
        board.place_piece(pawn, 5, 2)
        pawn.disable_double_step
      end

      it 'returns the square in front of the pawn' do
        expect(board.available_moves([5, 2])).to match(valid_moves)
      end
    end

    context 'when a pawn on a subsequent move has a blocked square' do
      before do
        pawn = Pawn.new(:white)
        pawn.disable_double_step
        board.place_piece(pawn, 5, 2)
        board.place_piece(Piece.new(:black), 6, 2)
      end

      it 'return an empty hash' do
        expect(board.available_moves([5, 2])).to be_empty
      end
    end

    context 'when no piece exist on the square' do
      it 'returns an empty hash' do
        expect(board.available_moves([4, 5])).to be_empty
      end
    end
  end

  describe '#available_attacks' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when a rook has available attacks' do
      let(:valid_attacks) do
        {
          [4, 1] => :attack,
          [0, 3] => :attack
        }
      end

      before do
        board.place_piece(Rook.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 4, 1)
        board.place_piece(Piece.new(:black), 4, 0)
        board.place_piece(Piece.new(:white), 6, 3)
        board.place_piece(Piece.new(:black), 7, 3)
        board.place_piece(Piece.new(:black), 0, 3)
      end

      it 'returns all non-blocked enemy-occupied orthogonal squares' do
        expect(board.available_attacks([4, 3])).to match(valid_attacks)
      end
    end

    context 'when a rook has no available attacks' do
      before do
        board.place_piece(Rook.new(:white), 4, 3)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([4, 3])).to be_empty
      end
    end

    context 'when a bishop has available attacks' do
      let(:valid_attacks) do
        {
          [5, 5] => :attack,
          [5, 1] => :attack
        }
      end

      before do
        board.place_piece(Bishop.new(:white), 3, 3)
        board.place_piece(Piece.new(:black), 5, 5)
        board.place_piece(Piece.new(:black), 6, 6)
        board.place_piece(Piece.new(:white), 1, 5)
        board.place_piece(Piece.new(:black), 0, 6)
        board.place_piece(Piece.new(:black), 5, 1)
      end

      it 'returns all non-blocked enemy-occupied diagonal squares' do
        expect(board.available_attacks([3, 3])).to match(valid_attacks)
      end
    end

    context 'when a bishop has no available attacks' do
      before do
        board.place_piece(Bishop.new(:white), 3, 3)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([3, 3])).to be_empty
      end
    end

    context 'when a queen has available attacks' do
      let(:valid_attacks) do
        {
          [3, 5] => :attack,
          [5, 5] => :attack,
          [5, 1] => :attack
        }
      end

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
        expect(board.available_attacks([3, 3])).to match(valid_attacks)
      end
    end

    context 'when a queen has no available attacks' do
      before do
        board.place_piece(Queen.new(:white), 3, 3)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([3, 3])).to be_empty
      end
    end

    context 'when a knight has available attacks' do
      let(:valid_attacks) do
        {
          [5, 1] => :attack,
          [2, 2] => :attack
        }
      end

      before do
        board.place_piece(Knight.new(:white), 4, 3)
        board.place_piece(Piece.new(:black), 5, 1)
        board.place_piece(Piece.new(:white), 2, 4)
        board.place_piece(Piece.new(:black), 2, 2)
      end

      it 'returns all enemy-occupied L-shaped attack squares' do
        expect(board.available_attacks([4, 3])).to match(valid_attacks)
      end
    end

    context 'when a knight has no available attacks' do
      before do
        board.place_piece(Knight.new(:white), 4, 3)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([4, 3])).to be_empty
      end
    end

    context 'when a king has available attacks' do
      let(:valid_attacks) do
        {
          [4, 4] => :attack,
          [4, 6] => :attack
        }
      end

      before do
        board.place_piece(King.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 4, 4)
        board.place_piece(Piece.new(:white), 5, 6)
        board.place_piece(Piece.new(:black), 4, 6)
      end

      it 'returns all enemy-occupied adjacent squares' do
        expect(board.available_attacks([4, 5])).to match(valid_attacks)
      end
    end

    context 'when a king has no available attacks' do
      before do
        board.place_piece(King.new(:white), 4, 5)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([4, 5])).to be_empty
      end
    end

    context 'when a pawn has available attacks' do
      let(:valid_attacks) do
        {
          [2, 0] => :attack
        }
      end

      before do
        board.place_piece(Pawn.new(:white), 1, 1)
        board.place_piece(Piece.new(:black), 2, 0)
        board.place_piece(Piece.new(:black), 2, 1)
        board.place_piece(Piece.new(:white), 2, 2)
      end

      it 'returns all enemy-occupied diagonally adjacent forward squares' do
        expect(board.available_attacks([1, 1])).to match(valid_attacks)
      end
    end

    context 'when a pawn has no available attacks' do
      before do
        board.place_piece(Pawn.new(:white), 1, 1)
      end

      it 'return an empty hash' do
        expect(board.available_attacks([1, 1])).to be_empty
      end
    end

    context 'when a pawn has an available en passant attack' do
      before do
        board.place_piece(Pawn.new(:white), 4, 4)
        board.place_piece(Pawn.new(:black), 6, 5)

        board.move_piece([6, 5], [4, 5])
      end

      it 'includes the en_passant attack' do
        expect(board.available_attacks([4, 4])).to include([5, 5] => :en_passant)
      end
    end

    context 'when no piece exist on the square' do
      it 'returns an empty hash' do
        expect(board.available_attacks([4, 5])).to be_empty
      end
    end
  end

  describe '#available_castling_moves' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when all castling conditions are met' do
      let(:valid_castling_moves) do
        {
          [0, 2] => :castling,
          [0, 6] => :castling
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 0)
        board.place_piece(Rook.new(:white), 0, 7)
      end

      it 'returns castling moves for both sides' do
        expect(board.available_castling_moves(:white)).to match(valid_castling_moves)
      end
    end

    context 'when the king has previously moved' do
      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 0)
        board.place_piece(Rook.new(:white), 0, 7)

        board.move_piece([0, 4], [1, 4])
        board.move_piece([1, 4], [0, 4])
      end

      it 'return an empty hash' do
        expect(board.available_castling_moves(:white)).to be_empty
      end
    end

    context "when there is a piece between the king and queen's rook" do
      let(:valid_castling_moves) do
        {
          [0, 6] => :castling
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 0)
        board.place_piece(Rook.new(:white), 0, 7)
        board.place_piece(Piece.new(:white), 0, 1)
      end

      it 'returns only the kingside castling move' do
        expect(board.available_castling_moves(:white)).to match(valid_castling_moves)
      end
    end

    context 'when the king is in check' do
      before do
        board.place_piece(King.new(:black), 7, 4)
        board.place_piece(Rook.new(:black), 7, 0)
        board.place_piece(Rook.new(:black), 7, 7)
        board.place_piece(Bishop.new(:white), 5, 6)
      end

      it 'return an empty hash' do
        expect(board.available_castling_moves(:black)).to be_empty
      end
    end

    context 'when queenside castling would land the king on a square controlled by the enemy' do
      let(:valid_castling_moves) do
        {
          [0, 6] => :castling
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 0)
        board.place_piece(Rook.new(:white), 0, 7)
        board.place_piece(Queen.new(:black), 5, 2)
      end

      it 'returns only the kingside castling move' do
        expect(board.available_castling_moves(:white)).to match(valid_castling_moves)
      end
    end

    context 'when kingside castling would cause the king to pass through a square controlled by the enemy' do
      let(:valid_castling_moves) do
        {
          [7, 2] => :castling
        }
      end

      before do
        board.place_piece(King.new(:black), 7, 4)
        board.place_piece(Rook.new(:black), 7, 0)
        board.place_piece(Rook.new(:black), 7, 7)
        board.place_piece(Queen.new(:white), 3, 5)
      end

      it 'returns only the queenside castling move' do
        expect(board.available_castling_moves(:black)).to match(valid_castling_moves)
      end
    end

    context "when the queen's rook is not present" do
      let(:valid_castling_moves) do
        {
          [0, 6] => :castling
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 7)
      end

      it 'returns only the kingside castling move' do
        expect(board.available_castling_moves(:white)).to match(valid_castling_moves)
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

      it 'does not permanently modify the board' do
        grid_before = board.grid.map(&:dup)
        board.prevents_check?([3, 2], [3, 4])
        expect(board.grid).to eq(grid_before)
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

      it 'does not permanently modify the board' do
        grid_before = board.grid.map(&:dup)
        board.prevents_check?([3, 2], [3, 4])
        expect(board.grid).to eq(grid_before)
      end
    end
  end

  describe '#checkmate?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the king is in checkmate' do
      before do
        board.place_piece(King.new(:white), 0, 7)
        board.place_piece(King.new(:black), 2, 7)
        board.place_piece(Bishop.new(:black), 2, 5)
        board.place_piece(Bishop.new(:black), 2, 4)
      end

      it 'returns true' do
        expect(board.checkmate?(:white)).to be true
      end
    end

    context 'when the king is not in checkmate' do
      before do
        board.place_piece(King.new(:white), 0, 7)
        board.place_piece(King.new(:black), 2, 7)
        board.place_piece(Bishop.new(:black), 2, 5)
      end

      it 'returns false' do
        expect(board.checkmate?(:white)).to be false
      end
    end

    context 'when the king is in stalemate' do
      before do
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Queen.new(:white), 5, 6)
        board.place_piece(King.new(:white), 0, 0)
      end

      it 'returns false' do
        expect(board.checkmate?(:black)).to be false
      end
    end
  end

  describe '#stalemate?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the king is in stalemate' do
      before do
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Queen.new(:white), 5, 6)
        board.place_piece(King.new(:white), 0, 0)
      end

      it 'returns true' do
        expect(board.stalemate?(:black)).to be true
      end
    end

    context 'when the king is not in stalemate' do
      before do
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Queen.new(:white), 5, 5)
        board.place_piece(King.new(:white), 0, 0)
      end

      it 'returns false' do
        expect(board.stalemate?(:black)).to be false
      end
    end

    context 'when the king is in checkmate' do
      before do
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Queen.new(:white), 5, 7)
        board.place_piece(King.new(:white), 6, 5)
      end

      it 'returns false' do
        expect(board.stalemate?(:black)).to be false
      end
    end
  end

  describe '#threefold_repetition?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'when the same positions occur three times' do
      before do
        board.place_piece(Piece.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 2, 6)

        3.times do
          board.move_piece([4, 5], [4, 6])
          board.move_piece([2, 6], [2, 7])
          board.move_piece([4, 6], [4, 5])
          board.move_piece([2, 7], [2, 6])
        end
      end

      it 'returns true' do
        expect(board.threefold_repetition?).to be true
      end
    end

    context 'when the same positions occur only twice' do
      before do
        board.place_piece(Piece.new(:white), 4, 5)
        board.place_piece(Piece.new(:black), 2, 6)

        2.times do
          board.move_piece([4, 5], [4, 6])
          board.move_piece([2, 6], [2, 7])
          board.move_piece([4, 6], [4, 5])
          board.move_piece([2, 7], [2, 6])
        end
      end

      it 'returns false' do
        expect(board.threefold_repetition?).to be false
      end
    end
  end

  describe '#insufficient_material?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'with the combination King vs King' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(King.new(:black), 7, 7)
      end

      it 'returns true' do
        expect(board.insufficient_material?).to be true
      end
    end

    context 'with the combination King + Bishop vs King' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Bishop.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
      end

      it 'returns true' do
        expect(board.insufficient_material?).to be true
      end
    end

    context 'with the combination King + Knight vs King' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Knight.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
      end

      it 'returns true' do
        expect(board.insufficient_material?).to be true
      end
    end

    context 'with the combination King + Bishop vs King + Bishop with bishops on the same color' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Bishop.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Bishop.new(:black), 6, 7)
      end

      it 'returns true' do
        expect(board.insufficient_material?).to be true
      end
    end

    context 'with the combination King + Bishop vs King + Bishop with bishops on opposite colors' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Bishop.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Bishop.new(:black), 5, 7)
      end

      it 'returns false' do
        expect(board.insufficient_material?).to be false
      end
    end

    context 'with the combination King + Bishop vs King + Pawn' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Bishop.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Pawn.new(:black), 6, 7)
      end

      it 'returns false' do
        expect(board.insufficient_material?).to be false
      end
    end

    context 'with the combination King + Knight vs King + Pawn' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Knight.new(:white), 1, 0)
        board.place_piece(King.new(:black), 7, 7)
        board.place_piece(Pawn.new(:black), 6, 7)
      end

      it 'returns false' do
        expect(board.insufficient_material?).to be false
      end
    end

    context 'with the combination King + Knight + Knight vs King' do
      before do
        board.place_piece(King.new(:white), 0, 0)
        board.place_piece(Knight.new(:white), 1, 0)
        board.place_piece(Knight.new(:white), 0, 1)
        board.place_piece(King.new(:black), 7, 7)
      end

      it 'returns false' do
        expect(board.insufficient_material?).to be false
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

    context 'with a king that is able to castle' do
      let(:castling_moves) do
        {
          [0, 2] => :castling,
          [0, 6] => :castling
        }
      end

      before do
        board.place_piece(King.new(:white), 0, 4)
        board.place_piece(Rook.new(:white), 0, 0)
        board.place_piece(Rook.new(:white), 0, 7)
      end

      it 'includes the castling moves' do
        expect(board.legal_moves([0, 4])).to include(castling_moves)
      end
    end
  end

  describe 'should_promote?' do
    subject(:board) { described_class.new(setup: :empty) }

    context 'with a white pawn on its final rank' do
      before do
        board.place_piece(Pawn.new(:white), 7, 3)
      end

      it 'returns true' do
        expect(board.should_promote?([7, 3])).to be true
      end
    end

    context 'with a white pawn not on its final rank' do
      before do
        board.place_piece(Pawn.new(:white), 6, 3)
      end

      it 'returns false' do
        expect(board.should_promote?([6, 3])).to be false
      end
    end

    context 'with a black pawn on its final rank' do
      before do
        board.place_piece(Pawn.new(:black), 0, 5)
      end

      it 'returns true' do
        expect(board.should_promote?([0, 5])).to be true
      end
    end

    context 'with a black pawn not on its final rank' do
      before do
        board.place_piece(Pawn.new(:black), 1, 5)
      end

      it 'returns false' do
        expect(board.should_promote?([1, 5])).to be false
      end
    end
  end
end
