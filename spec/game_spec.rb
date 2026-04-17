# frozen_string_literal: true

require './lib/game'

describe Game do
  subject(:game) { described_class.new }

  describe '#switch_player' do
    context 'when white is the current player' do
      it 'changes the current player to black' do
        expect { game.switch_player }.to change(game, :current_player).from(:white).to(:black)
      end
    end

    context 'when black is the current player' do
      before do
        game.switch_player
      end

      it 'changes the current player to white' do
        expect { game.switch_player }.to change(game, :current_player).from(:black).to(:white)
      end
    end
  end

  describe '#choose_start_square' do
    before do
      allow(game).to receive(:puts) # rubocop:disable RSpec/SubjectStub
    end

    context 'when the player chooses a valid square' do
      let(:start_square) { [1, 3] }
      let(:input_valid) { "d2\n" }

      before do
        allow(game).to receive(:ask_for_input).and_return(input_valid) # rubocop:disable RSpec/SubjectStub
      end

      it 'requests input once' do
        game.choose_start_square
        expect(game).to have_received(:ask_for_input).once # rubocop:disable RSpec/SubjectStub
      end

      it 'returns the valid square coordinates' do
        expect(game.choose_start_square).to eq(start_square)
      end
    end

    context 'when the player chooses an invalid square, then a valid square' do
      let(:start_square) { [1, 6] }
      let(:input_invalid) { "f1\n" }
      let(:input_valid) { "g2\n" }

      before do
        allow(game).to receive(:ask_for_input).and_return(input_invalid, input_valid) # rubocop:disable RSpec/SubjectStub
      end

      it 'requests input twice' do
        game.choose_start_square
        expect(game).to have_received(:ask_for_input).twice # rubocop:disable RSpec/SubjectStub
      end

      it 'returns the valid square coordinates' do
        expect(game.choose_start_square).to eq(start_square)
      end
    end

    context 'when the player enters bad input once, then chooses a valid square' do
      let(:start_square) { [0, 6] }
      let(:input_bad) { "bad input\n" }
      let(:input_valid) { "g1\n" }

      before do
        allow(game).to receive(:ask_for_input).and_return(input_bad, input_valid) # rubocop:disable RSpec/SubjectStub
      end

      it 'requests input twice' do
        game.choose_start_square
        expect(game).to have_received(:ask_for_input).twice # rubocop:disable RSpec/SubjectStub
      end

      it 'returns the valid square coordinates' do
        expect(game.choose_start_square).to eq(start_square)
      end
    end
  end
end
