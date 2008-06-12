require 'sdl'
require 'opengl'

class Main
  def initialize game
    @width, @height = 700, 700
    #puts @width, @height
    SDL.init SDL::INIT_VIDEO
    SDL::WM.set_caption "Elemental Chess", "pieces/fire1.png"
    SDL.setVideoMode @width,@height,16,SDL::OPENGL
    GL.Enable GL::TEXTURE_2D
    GL.Enable GL::BLEND
    GL.TexEnv GL::TEXTURE_ENV, GL::TEXTURE_ENV_MODE, GL::DECAL

    @game = game.new
    #@game.set_up

    @game.draw
    SDL.GLSwapBuffers

  end

  def input
    while event = SDL::Event2.poll
      case event
      when SDL::Event2::Quit : exit
      when SDL::Event2::MouseButtonDown
        @game.click_square [event.x, event.y], [@width, @height]
        #when SDL::Event2::KeyDown
      end
      @game.draw
      SDL.GLSwapBuffers
    end
  end

  def mainloop
    loop do
      input
    end
  end
end

class Texture
  @@textures = {}
  Prefix = "pieces/"
  def Texture.get file
    if loaded = @@textures[file]
      return loaded
    end

    image = SDL::Surface.load "#{Prefix}#{file}"
    index = GL.GenTextures(1)[0]
    GL.BindTexture GL::TEXTURE_2D, index

=begin
    GL.TexParameteri GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR
    GL.TexParameteri GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR
    GL.TexImage2D GL::TEXTURE_2D, 0, GL::RGBA, image.w, image.h, 0,
      GL::RGBA, GL::UNSIGNED_BYTE, image.pixels
=end
    GLU.Build2DMipmaps GL::TEXTURE_2D, GL::RGBA, image.w, image.h, GL::RGBA, 
      GL::UNSIGNED_BYTE, image.pixels

    # TODO: free sdl surface?

    @@textures[file] = index
    return index
  end
end


def start game
  Main.new(game).mainloop
end
