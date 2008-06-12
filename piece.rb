require 'opengl'

class Piece
  attr_accessor :owner, :space, :select
  def initialize opts = {}
    if @owner = opts[:owner]
      @owner.add_piece self
    end
    
    if @space = opts[:space]
      @space.occupant = self
    end

    #@texture = Texture.get "fire1.png"

    #@movement = [Cardinal+Diagonal,Repeat] # make it into an array of nth level perturbations, duplicating the last one forever
    #@movement_cycles = 50
  end

  def go new_square
    @space.remove_piece self
    new_square.add_piece self
    @space = new_square    
  end

  def lands_on piece
  end

  def draw
    glpush do
      color = if @owner then @owner.color
              else [0.5, 0, 0.5]; end
      scale = 0.9
      GL.Scale scale,scale,0
      GL.Translate( (1.0 - scale)/2, (1.0 - scale)/2, 0 )

      if @select
        color = color.map do |cell|
          cell + 0.15
        end
      end

      glcolor color

      GL.BindTexture GL::TEXTURE_2D, @texture

      glprim GL::QUADS do
        GL.TexCoord 0,1
        GL.Vertex 0,0,0
        GL.TexCoord 1,1
        GL.Vertex 1,0,0
        GL.TexCoord 1,0
        GL.Vertex 1,1,0
        GL.TexCoord 0,0
        GL.Vertex 0,1,0
      end
    end
  end

=begin
  def mark_possible_moves piece
    movements.each do |move|
      next unless square = @board.find_space(piece.square.x + move[0],piece.square.y + move[1])
      next if square.occupant && square.occupant.owner == @players[@active_player]

      @possible_moves.push square
      square.hilight = true
    end
  end
=end

  def check_movement
    board = @space.parent
    queue = [[@space,0,:none]]
    possible_moves = []

    while queue do
      break unless datum = queue.shift
      branch_square, steps, last_movement = datum
      break if steps >= @movement_cycles
      movement_set = steps >= @movement.size ? @movement[@movement.size-1] : @movement[steps]
      movement_set.each do |hop|
        if hop == :repeat
          hop = last_movement
        end
        #puts hop,[last_movement]

        next unless check_square = board.find_space(branch_square.x + hop[0], branch_square.y + hop[1])
        #puts check_square

        # apply restrictions for arriving here
        next if check_square.occupant && check_square.occupant.owner == @owner # can't squish your own pieces

        # if it's a new square, add it
        if check_square.hilight == false
          possible_moves.push check_square
          check_square.hilight = true

          # apply restrictions for leaving here
          next if check_square.occupant

          queue.push [check_square,steps+1,hop]
        end
      end
    end
    return possible_moves
  end


=begin
  Cardinal = [[-1,0],[1,0],[0,1],[0,-1]]
  Diagonal = [[1,1],[1,-1],[-1,-1],[-1,1]]
  Knight   = [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[-1,2],[1,-2],[-1,-2]]
  Repeat   = [:repeat]
=end

  def orthogonal_distance source, destination
    (source.x - destination.x).abs + (source.y - destination.y).abs
  end

  def diagonal_distance source, destination
    [(source.x - destination.x).abs, (source.y - destination.y).abs].max
  end

  def real_distance source, destination
    ((source.x - destination.x)**2 + (source.y - destination.y)**2)**(1/2)
  end
end



