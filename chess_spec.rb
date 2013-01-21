require './chess.rb'

describe Game do

	subject(:game) { Game.new }

	it "should initialize with a board 8 deep" do
		game.board.count.should eq(8)
	end

	it "should initialize with a board 8 wide" do
		game.board[0].count.should eq(8)
		game.board[1].count.should eq(8)
		game.board[2].count.should eq(8)
		game.board[3].count.should eq(8)
		game.board[4].count.should eq(8)
		game.board[5].count.should eq(8)
		game.board[6].count.should eq(8)
		game.board[7].count.should eq(8)
	end



end