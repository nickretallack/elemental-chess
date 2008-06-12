require 'opengl'
require 'space'
require 'vector'
include Geometry

=begin TODO!!!
  Try indexing the hashmap with link coordinates that lead to a square,
  instead of just using its center point.
  That way we could have some really abnormal maps =].
=end


Cardinal =  [Vector.new(1,0),Vector.new(-1,0),Vector.new(0,1),Vector.new(0,-1)]
Diagonal =  [Vector.new(1,1),Vector.new(-1,-1),Vector.new(-1,1),Vector.new(1,-1)]

class Board
  def initialize
    @draw_mark_toggle = false
    @spaces = {}
  end

  def add_piece loc, piece
    if space = find_space(loc)
      space.add_piece piece
    else
      puts "ERROR: couldn't place #{piece} at #{x}, #{y}"
    end
  end

  def register_space space, position
    @spaces[[position[0],position[1]]] = space
  end

  def mark spaces, mark
    spaces.to_a.each do |square|
      square.hilight = mark
    end
  end

=begin # THIS WILL BE USEFUL LATER
  def grow
    stubs = [Vector.new(1,0),Vector.new(-1,0),Vector.new(0,1),Vector.new(0,-1)]
    @root = Space.new :stubs => stubs
    @root.hilight = true
    queue = [[@root,0]]
    while data = queue.shift
      space,steps = data
      while stub = space.stubs.pop do

        size = 5

        # stop spaces here
        new_pos = space.position + stub
        next if new_pos[0] > size || new_pos[0] < 0 || new_pos[1] > size || new_pos[1] < 0 
        #puts "Making a space at #{new_pos}"

        a_space = Space.new :position => new_pos, :stubs => stubs
        queue.push [a_space,steps+1]
      end
    end
  end
=end

  def find_space coord
    @spaces[coord.to_a]
  end

  def draw
    @spaces.each do |pos,space|
      space.draw
    end
  end

=begin # old method uses a BFS, but why not just use the list instead
    queue = [@root]
    while space = queue.shift
      # draw the space
      #puts "Space: #{space}"
      space.draw
      #puts "drawing #{space.object_id} at #{space.position}"

      # queue up its links
      space.links.each do |link|
        #puts "link: #{link.object_id} at #{link.position}, drawn: #{link.drawn}"
        if link.drawn == @draw_mark_toggle #@draw_mark_toggle
          queue.push link
          link.drawn = !@draw_mark_toggle
         # puts "drawing #{link.position}. toggle: #{@draw_mark_toggle}, space: #{link.drawn}"
        end

        # when we decide on movement, this would be the place that we
        # cull out links if we're required to be moving straight at this point

      end
    end
=end
  @draw_mark_toggle = !@draw_mark_toggle
end


=begin
    GL.Translate -@board.length/2, -@board[0].length/2, 0
    @board.each_index do |row|
      glpush do
        @board[row].each_index do |col|
          GL.LoadName row * @board.length + col
          @board[row][col].draw
          GL.Translate 0,1.05,0
        end
      end
      GL.Translate 1.05,0,0
    end
=end

class RectangularBoard < Board

  def initialize size, space
    super()
    @size = size
    1.upto(@size[0]) do |x|
      1.upto(@size[1]) do |y|
        space.new :position => Vector.new(x,y),
          :links => Cardinal + Diagonal,
          :board => self
      end
    end
  end

  def width; @size[0];  end

  def height; @size[1]; end

  def draw
    glpush do
      GL.Translate -@size[0]/2.0 -0.95,-@size[1]/2.0 - 0.95,0 
      #GL.Translate -1.5,-1.5,0 
      super
    end
  end

  def find_space coords
    coords[0] = @size[0] if coords[0] == :right
    coords[1] = @size[1] if coords[0] == :top
    
    coords[0] = 0 if coords[0] == :left
    coords[1] = 0 if coords[0] == :bottom

    super(coords)
  end
end

