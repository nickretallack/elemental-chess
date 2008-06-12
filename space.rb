require 'opengl'
require 'vector'
include Geometry

class Space                    #rename board
  attr_accessor :occupant, :hilight, :drawn
  attr_accessor :board, :links, :position

  # list is indexed by id
  @@list = [] 
  @@last_id = 0

  def initialize opts = {}
    @position = opts[:position] || Vector.new(0,0)
    @links = opts[:links].clone || []
    @board = opts[:board]
    @occupant = opts[:occupant]
    @drawn = false # toggling marker for rendering with BFS

    register
  end

  def add_piece piece
    piece.lands_on @occupant if @occupant
    @occupant = piece
    piece.space = self
    space_effect piece
  end

  def space_effect piece
  end

  def remove_piece piece
    @occupant = nil
  end

  def register
    @board.register_space self, @position
    @id = @@last_id
    @@list[@id] = self
    @@last_id += 1
  end

  def neighbors
    #puts @links
    results = @links.map do |link|
      board.find_space @position + link
    end
    results.delete_if {|x| x == nil}
  end

  def jumps offsets
    #puts "offsets: #{offsets[0]}, @position: #{@position}"
    result = offsets.map do |jump|
      board.find_space @position + jump
    end
    result.delete_if {|x| x == nil}
  end

  def cardinals
    (@links - Diagonal).map {|link| board.find_space @position + link }.delete_if {|spot| spot==nil}
  end

  def diagonals
    (@links - Cardinal).map {|link| board.find_space @position + link }.delete_if {|spot| spot==nil}
  end


  def draw
    #puts "drawn? #{@drawn} to #{drawn} to #{self.drawn}"
    glpush do
      GL.Translate @position[0], @position[1], 0
      GL.LoadName @id

      if @hilight then GL.Color 1,1,0
      else GL.Color 1,1,1; end

      shrink = 0.9
      GL.Scale shrink,shrink,shrink
      glprim GL::QUADS do
        GL.Vertex 0,0,0
        GL.Vertex 1,0,0
        GL.Vertex 1,1,0
        GL.Vertex 0,1,0
      end

      @occupant.draw if @occupant
    end
  end

  # for opengl picking
  def Space.find id
    @@list[id]
  end


=begin TODO
  def go vector
    @links.each do |link|
      offset = 
  end
=end

end
