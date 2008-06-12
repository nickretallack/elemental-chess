# graphics
require 'opengl'
require 'glhelper'
require 'sdl_shell'

# components
require 'player'
require 'piece'
require 'board'
require 'space'

class Game
  def initialize
    @board = nil
    @active_piece = nil
    @active_player = 0
    @game_state = :begun
    @title = "Board Game"

    set_up
  end

  def active_player
    @players[@active_player]
  end

  def draw
    GL.MatrixMode GL::MODELVIEW
    GL.Clear GL::COLOR_BUFFER_BIT
    GL.LoadIdentity

    scaledown = 1.0 / ( [@board.width,@board.height].max / 2.0 )
    GL.Scale scaledown, scaledown, scaledown
    @board.draw
  end

  def click_square mouse, screen
    return if @game_state == :over
    square_id = select(screen, mouse) do
      draw
    end
    return unless square_id
    square = Space.find square_id
    #square.hilight = true
    if square.occupant && square.occupant.owner == @players[@active_player]
      clear_moves

      @active_piece = square.occupant
      @active_piece.select = true
      #puts @active_piece.space.neighbors
      @possible_moves = @active_piece.check_movement
      @board.mark @possible_moves, true
    elsif @active_piece
      try_moving square
    end
  end

  def remove_player player
    @players.delete player
    if @players.size == 1
      declare_winner @players[0]
    end
  end
    
  def declare_winner player
    puts "#{player.name} wins!"
    @game_state = :over
  end

  def clear_moves
    @board.mark @possible_moves, false
    @possible_moves = []
    @active_piece.select = false if @active_piece
  end


=begin
  def mark_possible_moves piece
    movements = [[-1,0],[1,0],[0,1],[0,-1]]
    movements.each do |hop|
      next unless square = @board.find_space(piece.square.x + hop[0],piece.square.y + hop[1])
      next if square.occupant && square.occupant.owner == @players[@active_player]

      @possible_moves.push square
      square.hilight = true
    end
  end
=end

  def try_moving square
    if @possible_moves.include? square
      # clear off the old hilighted squares
      clear_moves

      @active_piece.go square
      @active_piece = nil
      @active_player = ( @active_player +1 ) % @players.length
    end
  end
end
