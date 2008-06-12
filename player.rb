class Player
  attr_accessor :pieces, :color, :game, :name, :id
  def Player.active
    @@players[@@active_player]
  end

  @@last_id = 0

  def initialize opts = nil
    @color = opts[:color] || [rand(),rand(),rand()]
    @pieces = []
    @game = opts[:game]

    @@last_id += 1
    @id = @@last_id
    @name = opts[:name] || "Player #{@@last_id}"
  end

  def add_piece piece
    @pieces.push piece
    #piece.owner = self
  end

  def loses
    puts "#{self.name} loses."
    @game.remove_player self    
  end
end

