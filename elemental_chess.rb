require 'game'

class ElementalGame < Game
  attr_accessor :title


  SetUp = [[{:kind=>:fire,:level=>3},{:kind=>:water,:level=>3},{:kind=>:familiar},{:kind=>:shield},{:kind=>:plant,:level=>3},{:kind=>:water,:level=>2}],[{:kind=>:plant,:level=>2},{:kind=>:fire,:level=>1},{:kind=>:water,:level=>1},{:kind=>:caster},{:kind=>:plant,:level=>1},{:kind=>:fire,:level=>2}]]

  def setup_player player, mapping
    SetUp.each_with_index do |row,y|
      row.each_with_index do |opts,x|
        opts[:owner] = player
        @board.add_piece mapping[x,y],ElementalPiece.new(opts)
      end
    end
  end


  def set_up
    @title = "Elemental Chess"

    orange = [1,0.6,0.3] 
    lightblue = [0.6,0.8,1] 
    pink   = [1,0.6,1]
    purple   = [0.8,0.6,1]

    @board = RectangularBoard.new [6,7], ElementalSpace
    # players
    @players = [Player.new( :color => orange, :game => self, :name => "Orange player" ),
      Player.new( :color => purple, :game => self, :name => "Purple player" )]

    setup_player @players[0], Proc.new{|x,y| [x+1,y+1]}
    setup_player @players[1], Proc.new{|x,y| [@board.width-x,@board.height-y]}
  end
end

class ElementalPiece < Piece
  attr_accessor :kind, :level
  def initialize opts = {}
    super

    # :kind - :fire :water :plant
    @kind = opts[:kind]   || :fire

    # set up movement pattern
    case @kind
    when :caster,:familiar,:shield
      @movement = Diagonal + Cardinal
    else
      @movement = Cardinal
    end

    @level = opts[:level] || 1

    @texture = Texture.get Textures[[@kind,@level]]
  end

  def lands_on piece
    if piece.kind == :caster
      piece.owner.loses
    end
  end

  def shielded
    @space.neighbors.each do |space|
      if bystander = space.occupant
        if bystander.kind == :shield && bystander.owner == @owner
          return true
        end
      end
    end
    return false
  end

  def check_movement
    jumps = @space.jumps( @movement )

    jumps.delete_if do |space|
      if foe = space.occupant
        if foe.owner == @owner then true
        elsif foe.kind == @kind
          case @kind
          when :caster,:shield : true
          else
            if foe.level >= @level then true; end
          end
        else
          if foe.type_beats self then true; end
        end
      end
    end
  end



  Beats = { :fire => :plant, :plant => :water, :water => :fire }

  def type_beats piece

    case piece.kind
    when :caster:
      return true unless @kind == :familiar or @kind == :shield
    when :shield: true
    when :familiar:
      if @level > piece.level or @kind == :caster then true; end
    else
      if (@kind == :familiar or @kind == :caster) && self.shielded then true
      elsif Beats[@kind] == piece.kind then true
      end
    end
  end

  def upgrade
    @level += 1
    @texture = Texture.get Textures[[@kind,@level]]
  end

  Textures = { [:fire,1] => "fire1.png",
    [:fire,2] => "fire2.png",
    [:fire,3] => "fire3.png",
    [:water,1] => "water1.png",
    [:water,2] => "water2.png",
    [:water,3] => "water3.png",
    [:plant,1] => "plant1.png",
    [:plant,2] => "plant2.png",
    [:plant,3] => "plant3.png",
    [:caster,1] => "caster.png", 
    [:familiar,1] => "familiar1.png",
    [:familiar,2] => "familiar2.png",
    [:shield,1] => "shield.png" }

end

class ElementalSpace < Space
  def space_effect piece
    if piece.kind == :familiar
      if piece.owner.id == 2 && @position[1] == 1
        piece.upgrade
      elsif piece.owner.id == 1 && @position[1] == @board.height
        piece.upgrade
      end
    end
  end
end

start ElementalGame
