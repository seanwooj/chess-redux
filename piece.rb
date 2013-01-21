class Piece
		BOARD_LENGTH = 8
		DIAGONALS = [[-1, -1], [-1, 1], [1, -1], [1, 1]]
		VERTICAL_HORIZONTAL = [[1, 0], [-1, 0], [0, 1], [0, -1]]
		KNIGHT = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, -2], [1, 2], [-1, -2], [-1, 2]]

		# unicode doesn't work on CMD in windows for whatever reason.
		ICONS = {
	    :white => {
	      king: "WK",
	      queen: "WQ",
	      rook: "WR",
	      bishop: "WB",
	      knight: "WK",
	      pawn: "WP"
	    },
	    :black => {
	      king: "BK",
	      queen: "BQ",
	      rook: "BR",
	      bishop: "BB",
	      knight: "BK",
	      pawn: "BP"
	    }
	  }

		attr_accessor :color, :position, :icon

		def initialize(color, game)
			@color = color
			@game = game
			# This ugly bit of code assigns icons to each class automatically
    	@icon = ICONS[color][self.class.to_s.downcase.to_sym]
		end

		def position(row=nil, col=nil)
			unless row.nil? || col.nil?
				@position = [row,col]
			else
				@position
			end
		end

		# Pruning illegal moves
			def in_bounds?(coordinates)
				# do the coordinates that are passed in sit in the board?
	    	coordinates.all? { |coord| (0..BOARD_LENGTH-1).include?(coord) }
	  	end

	  	def valid_moves
		    valid_moves = []
		    self.moves.each do |move_coord|
		    	blocking_enemies = 0
		      row, col = self.position
		      move_chain = []
		      while in_bounds?([row + move_coord[0], col + move_coord[1]]) && move_chain.size < self.max_distance
		        move = [row + move_coord[0], col + move_coord[1]]
		        break if occupied_by_team?(move)
		        blocking_enemies += enemy_counter(move)
		        break if blocking_enemies > 1
		        p blocking_enemies
		        move_chain << move
		        row += move_coord[0]
		        col += move_coord[1]
		      end
		      valid_moves << move_chain
		    end
		    valid_moves
		  end

		  def occupied_by_team?(move)
		    row, col = move
	      piece = @game.piece_at(row,col)
	      if piece == :blank || piece.color != self.color
	       	false
	      else
	        true
	      end
		  end

		  def enemy_counter(move)
		  	row, col = move
	      piece = @game.piece_at(row,col)
	      if piece != :blank
	      	if piece.color != self.color
	       		1
	       	else
	       		0
	       	end
	      else
	        0
	      end
		  end


end

class Pawn < Piece

	attr_reader :moves, :max_distance

	def initialize(color, game)
		super(color, game)
		@moves = [
	    [1,0], # black
	    [2,0], # black
	    [1,1], # black
	    [1,-1],# black
	    [-1,0], # white
	    [-2,0], # white
	    [-1,-1], # white
	    [-1,1] # white
	  ]
	  @max_distance = 1

	end

	

  def valid_moves
  	all_moves = @moves.map do |(row,col)|
      [@position[0] + row, @position[1] + col]
    end

    all_moves = filter_on_color(all_moves)
    all_moves = filter_on_jump(all_moves)
    all_moves = filter_on_attack(all_moves)
    @moves = filter_when_blocked(all_moves)
    @moves.map! do |coords|
    	row, col = coords
    	[row - @position[0], col - @position[1]]
    end
  	valid_moves = super
  	@moves = [
	    [1,0], # black
	    [2,0], # black
	    [1,1], # black
	    [1,-1],# black
	    [-1,0], # white
	    [-2,0], # white
	    [-1,-1], # white
	    [-1,1] # white
	  ]
	  valid_moves
  end

  def filter_on_color(moves)
  	p moves
    if self.color == :black
      moves.select do |coords|
        coords[0] > self.position[0]
      end
      moves
    else # :white
      moves.select do |coords|
        coords[0] < self.position[0]
      end
      moves
    end
  end

  def filter_on_jump(moves)
    if self.color == :black
      unless self.position[0] == 1
        moves.select do |coords|
          coords[0] == self.position[0] + 1
        end
      end
    else
      unless self.position[0] == 6
        moves.select do |coords|
          coords[0] == self.position[0] - 1
        end
      end
    end
    moves
  end

  def filter_when_blocked(all_moves)
    if self.color == :black
      row, col = @position
      if @game.piece_at(row+1, col) != :blank
        all_moves.select! do |(r,c)|
          c != self.position[1]
        end
      end
    else
      row, col = @position
      if @game.piece_at(row-1, col) != :blank
        all_moves.select! do |(r,c)|
          c != self.position[1]
        end
      end
    end
    all_moves
  end

  def filter_on_attack(all_moves)
    # row, col = @position
    if self.color == :black
      row, col = @position
      if @game.piece_at(row+1, col + 1) == :blank
      	puts "you can't move to the bottom right"
      	all_moves.select!{ |move| move != [row+1, col + 1]}
      end
      if @game.piece_at(row+1, col - 1) == :blank
      	puts "you can't move to the bottom left"
      	all_moves.select!{ |move| move != [row+1, col - 1]}
      end
    else
      row, col = @position
      if @game.piece_at(row-1, col + 1) == :blank
      	puts "you can't move to the top right"
      	all_moves.select!{ |move| move != [row-1, col + 1]}
      end
      if @game.piece_at(row-1, col - 1) == :blank
      	puts "you can't move to the top left"
      	all_moves.select!{ |move| move != [row-1, col - 1]}
      end
    end
    all_moves
  end
end

class King < Piece
	attr_reader :moves, :max_distance
	def initialize(color, game)
		super(color, game)
		@moves = DIAGONALS + VERTICAL_HORIZONTAL
		@max_distance = 1
	end
end

class Queen < Piece
	attr_reader :moves, :max_distance
	def initialize(color, game)
		super(color, game)
		@moves = DIAGONALS + VERTICAL_HORIZONTAL
		@max_distance = 8
	end
end

class Rook < Piece
	attr_reader :moves, :max_distance
	def initialize(color, game)
		super(color, game)
		@moves = VERTICAL_HORIZONTAL
		@max_distance = 8
	end
end

class Knight < Piece
	attr_reader :moves, :max_distance
	def initialize(color, game)
		super(color, game)
		@moves = KNIGHT
		@max_distance = 1
	end
end

class Bishop < Piece
	attr_reader :moves, :max_distance
	def initialize(color, game)
		super(color, game)
		@moves = DIAGONALS
		@max_distance = 8
	end
end

