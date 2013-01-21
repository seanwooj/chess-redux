class Game
	attr_accessor :board

	def initialize
		@board = create_board
    populate_board
    ppd #debug
    return "Game Loaded"
	end

  # Play Loop
    def play
      ppd #debug
      until game_over?
        move = get_player_move
        source_row, source_col, target_row, target_col = move
        perform_move(source_row, source_col, target_row, target_col)
        toggle_player
      end
    end

    def game_over?
      false
    end

    def get_player_move

    end

	# SAVEGAME OPTIONS
  	def save_game
      puts "Save your game!"
      print "What do you want to save your game as? >"
      save_game = gets.chomp
      File.open("#{save_game}.chess", "w") do |file|
        file.write(self.to_yaml)
      end
    end

    def self.load_game
      puts "Load yo game!"
      print "What is your game saved as? >"
      saved_game = gets.chomp
      file = File.readlines("#{saved_game}.chess").join
      YAML.load(file)
    end

  # Board initialize
  def create_board
  	board = Array.new(8) { Array.new(8, :blank) }
  end

  def populate_board
    # black pawns
    @board[1].each_with_index do |cell, i|
      piece_at(1, i, Pawn.new(:black, self))
    end
    # white pawns
    @board[6].each_with_index do |cell, i|
      piece_at(6, i, Pawn.new(:white, self))
    end
    #black rooks
    piece_at(0,0, Rook.new(:black, self))
    piece_at(0,7, Rook.new(:black, self))
    #white rooks
    piece_at(7,0, Rook.new(:white, self))
    piece_at(7,7, Rook.new(:white, self))
    #black knights
    piece_at(0,1, Knight.new(:black, self))
    piece_at(0,6, Knight.new(:black, self))
    #white knights
    piece_at(7,1, Knight.new(:white, self))
    piece_at(7,6, Knight.new(:white, self))
    #black bishops
    piece_at(0,2, Bishop.new(:black, self))
    piece_at(0,5, Bishop.new(:black, self))
    #white bishops
    piece_at(7,2, Bishop.new(:white, self))
    piece_at(7,5, Bishop.new(:white, self))
    #black royals
    piece_at(0,3, Queen.new(:black, self))
    piece_at(0,4, King.new(:black, self))
    #white royals
    piece_at(7,3, Queen.new(:white, self))
    piece_at(7,4, King.new(:white, self)) 
  end

  # UI

  # Dev ch347c0d35
    def ppd
      puts "   0  1  2  3  4  5  6  7"
      puts "  _______________________"
      @board.each_with_index do |row, row_index|
        print "#{row_index}| "
        row.each_with_index do |cell, col_index|
          piece = piece_at(row_index, col_index)
          unless piece == :blank
            print piece.icon + " "
          else
            print "__ "
          end
        end
        puts
      end
      nil
    end

    def ds(row, col, &blk)
      piece_at(row,col, blk.call)
      ppd
    end

    def dr(row, col)
      piece_at(row,col, :blank)
      ppd
    end

  # Getter/Setter for Pieces
  def piece_at(row, col, value=nil)
    unless value == nil
      @board[row][col] = value
      value.position(row,col) unless value == :blank
    else
      @board[row][col]
    end
  end

  # Movement
    def change_position(source_row, source_col, target_row, target_col)
      moving_piece = piece_at(source_row, source_col)
      piece_at(target_row,target_col,moving_piece)
      piece_at(source_row,source_col,:blank)
      ppd #debug
    end

    def perform_move(source_row, source_col, target_row, target_col)
      if valid_move?(source_row, source_col, target_row, target_col)
        change_position(source_row, source_col, target_row, target_col)
      end
    end

    def valid_move?(source_row, source_col, target_row, target_col)
      if piece_at(source_row, source_col) == :blank
        return false
      else
        valid_moves = flatten_moves(piece_at(source_row, source_col).valid_moves)
        # p valid_moves
        # p [target_row, target_col]
        if valid_moves.include?([target_row, target_col])
          return true
        else
          return false
        end
      end
    end

    # takes an array formatted like [[[]],[],[[],[]]] and turns it into [[],[],[],[]]
    def flatten_moves(array_of_moves)
      flattened_array = []
      array_of_moves.each do |array|
        array.each do |moves|
          if moves != nil
            flattened_array << moves
          end
        end
      end
      flattened_array
    end


end