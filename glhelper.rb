# Nicholas Retallack -- nretalla
# 
# Some helper routines to make opengl a little more fun

def glprim type = GL::TRIANGLES
  GL.Begin type
  begin
    yield
  ensure
    GL.End
  end
end

def glpush
  GL.PushMatrix
  begin
    yield
  ensure
    GL.PopMatrix
  end
end

def drawsquare radius
  glprim GL::QUADS do
    GL.Vertex 0,        0, 0
    GL.Vertex radius,  0, 0
    GL.Vertex radius,  radius, 0
    GL.Vertex 0,       radius, 0
  end
end

def drawcircle radius, granularity = 30
  glprim GL::POLYGON do
    0.upto( granularity ) do |step|
      angle = ( 2*PI / granularity ) * step
      GL.Vertex radius*sin(angle), radius*cos(angle), 0
    end
  end
end


def gllist type = GL::COMPILE
  list = GL.GenLists 1
  GL.NewList list, type
  begin
    yield
  ensure
    GL.EndList
    return list
  end
end


class Squish
  def initialize direction, compression
    @angle = (180.0 / PI) * atan2( direction[1], direction[0] )
    @squish = [1-compression, 0].max
  end

  def apply
    GL.Rotate @angle, 0,0,1     # get to the axis of compression
    GL.Scale  @squish, 1,1      # squish it
    GL.Rotate -@angle, 0,0,1    # and undo the rotation
  end
end

def select screen, mouse
  viewport = [0,0,screen[0],screen[1]]
  select_buffer = GL.SelectBuffer 512
  GL.RenderMode GL::SELECT

  GL.InitNames
  GL.PushName 0 # Push a placeholder name so LoadName can work
  GL.MatrixMode GL::PROJECTION
  glpush do
    GLU.PickMatrix mouse[0], screen[0] - mouse[1], 1, 1, viewport
    yield # draw stuff
    GL.MatrixMode GL::PROJECTION
  end
  GL.Flush
  hits = GL.RenderMode GL::RENDER
  #puts "hits: " + hits.to_s
  target = process_hits hits, select_buffer
end

def process_hits hits, buffer
  ptr = buffer.unpack("I*")
  ptr[3] unless hits == 0
end


def glcolor c
  GL.Color c[0], c[1], c[2]
end
