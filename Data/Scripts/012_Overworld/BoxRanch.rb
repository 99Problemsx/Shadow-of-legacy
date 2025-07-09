#===============================================================================
# * Box Ranch System
#===============================================================================

class Game_Character
  def name
    return @character_name || ""
  end
end

class BoxRanch
  def initialize
    @pokemon = []
    @sprites = []
    @map_id = 117  # Hier die Map-ID der Ranch eintragen
    @viewport = nil
    p "BoxRanch initialized with map_id: #{@map_id}"
  end

  def setup_ranch_pokemon
    p "Current map_id: #{$game_map.map_id}, Target map_id: #{@map_id}"
    return if $game_map.map_id != @map_id
    
    # Debug-Ausgabe
    p "Setting up ranch pokemon on map #{@map_id}"
    
    # Lösche alte Sprites
    dispose_sprites
    
    # Erstelle Viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 200  # Höher als normale Map-Sprites
    
    # Hole Pokémon aus der Box
    for i in 0...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        pkmn = $PokemonStorage[i,j]
        next if !pkmn
        @pokemon.push(pkmn)
      end
    end
    
    # Debug-Ausgabe
    p "Found #{@pokemon.length} pokemon in storage"
    
    # Erstelle Sprites für jedes Pokémon
    @pokemon.each_with_index do |pkmn, index|
      sprite = Sprite_Character.new(@viewport, create_character(pkmn, index))
      @sprites.push(sprite)
    end
  end

  def dispose_sprites
    @sprites.each { |sprite| sprite.dispose if sprite }
    @sprites.clear
    @viewport.dispose if @viewport
    @viewport = nil
    @pokemon.clear
  end

  def create_character(pkmn, index)
    char = Game_Character.new
    char.transparent = false
    
    # Setze Sprite
    char_name = pkmn.species.to_s
    char_name += "_1" if pkmn.form > 0
    char.character_name = char_name
    char.character_hue = 0
    
    # Setze Position (hier können Sie die Positionierung anpassen)
    # Verteile die Pokémon in einem 5x5 Raster
    grid_x = index % 5
    grid_y = index / 5
    base_x = 5  # Startposition X
    base_y = 5  # Startposition Y
    spacing = 3  # Abstand zwischen den Pokémon
    
    char.instance_variable_set(:@x, base_x + (grid_x * spacing))
    char.instance_variable_set(:@y, base_y + (grid_y * spacing))
    char.instance_variable_set(:@real_x, (base_x + (grid_x * spacing)) * 128)
    char.instance_variable_set(:@real_y, (base_y + (grid_y * spacing)) * 128)
    
    # Debug-Ausgabe
    p "Created character for #{pkmn.name} at position (#{char.instance_variable_get(:@x)}, #{char.instance_variable_get(:@y)})"
    
    # Setze Bewegungsmuster
    char.move_speed = 3
    char.move_frequency = 3
    char.walk_anime = true
    char.animation_id = 0
    char.instance_variable_set(:@direction_fix, false)
    char.instance_variable_set(:@passable, true)
    char.instance_variable_set(:@through, false)
    char.instance_variable_set(:@always_on_top, false)
    
    return char
  end

  def update
    return if $game_map.map_id != @map_id
    @sprites.each { |sprite| sprite.update if sprite }
  end
end

#===============================================================================
# * Game_Map
#===============================================================================

class Game_Map
  alias box_ranch_setup setup
  def setup(map_id)
    p "Game_Map setup called with map_id: #{map_id}"
    box_ranch_setup(map_id)
    if $box_ranch
      p "Calling setup_ranch_pokemon"
      $box_ranch.setup_ranch_pokemon
    else
      p "BoxRanch not initialized!"
    end
  end
end

#===============================================================================
# * Scene_Map
#===============================================================================

class Scene_Map
  alias box_ranch_update update
  def update
    box_ranch_update
    $box_ranch.update if $box_ranch
  end
end

#===============================================================================
# * Game_System
#===============================================================================

class Game_System
  alias box_ranch_initialize initialize
  def initialize
    box_ranch_initialize
    p "Initializing BoxRanch"
    $box_ranch = BoxRanch.new
  end
end 