require 'sdl'
require 'glhelper'

require 'vector'

require 'board'
require 'piece'
require 'sdl_shell'

include Geometry
include Math



class Movement
  #Forward = Vector.new 0,1

  def initialize move
    @move = move
  end

=begin
  def align forward
    angle   = acos( forward*@move / forward.magnitude )
    matrix  = [[cos(angle),sin(angle),0]
    aligned = 


  end
=end

  def flipx
  end

  def flipy
  end
end

=begin
Kinds of movement:
moving to unhindered blank spaces
stomping on enemies
jumping over enemies / charging through them
=end



class LackeyPiece < Piece
  attr_accessor :level,:type
end

class SpecielPiece < Piece
end

