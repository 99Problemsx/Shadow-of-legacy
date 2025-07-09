#===============================================================================
# * Box Ranch System
#===============================================================================

# Helper function to load the correct Pokémon graphic
def box_ranch_sprite_filename(species, form = 0, gender = 0, shiny = false, in_water = false, levitates = false)
  fname = nil
  folder_extra = ""
  
  # Determine the correct folder based on properties
  if in_water
    folder_extra = shiny ? "Swimming Shiny" : "Swimming"
  elsif levitates
    folder_extra = shiny ? "Levitates Shiny" : "Levitates"
  else
    folder_extra = shiny ? "Followers shiny" : "Followers"
  end
  
  # Check various paths
  begin
    fname = GameData::Species.check_graphic_file("Graphics/Characters/", species, form, gender, shiny, false, folder_extra)
  rescue
    # Ignore errors and try another path
  end
  
  # Fallbacks
  if nil_or_empty?(fname)
    # Try directly with the name for the corresponding folder
    species_name = species.to_s
    fname = "Graphics/Characters/#{folder_extra}/#{species_name}"
    
    # If the file exists, use it
    if !pbResolveBitmap(fname)
      # Fallback to the default folder if the special version does not exist
      if in_water || levitates
        # Try the normal Followers folder
        fname = "Graphics/Characters/Followers/#{species_name}"
        if !pbResolveBitmap(fname)
          # Final fallback to standard sprite
          fname = "Graphics/Characters/Followers/000"
        end
      else
        # Use standard sprite
        fname = "Graphics/Characters/Followers/000"
      end
    end
  end
  
  return fname
end

# Helper function to check if a Pokémon is a Water type
def is_water_pokemon?(pokemon)
  return false if !pokemon
  
  # Check if the Pokémon has the Water type
  pokemon_types = [pokemon.type1, pokemon.type2]
  return pokemon_types.include?(:WATER)
end

# Helper function to check if a Pokémon can levitate
def is_levitating_pokemon?(pokemon)
  return false if !pokemon
  
  # List of Pokémon that can levitate
  levitating_species = [
    # Gen 1-3
    :GASTLY, :HAUNTER, :GENGAR, :KOFFING, :WEEZING, :PORYGON,
    :MISDREAVUS, :UNOWN, :NATU, :XATU, :ESPEON, :MURKROW, :WOBBUFFET,
    :GIRAFARIG, :PINECO, :DUNSPARCE, :GLIGAR, :LUGIA, :CELEBI,
    :DUSTOX, :SHEDINJA, :NINJASK, :WHISMUR, :LOUDRED, :EXPLOUD,
    :VOLBEAT, :ILLUMISE, :FLYGON, :BALTOY, :CLAYDOL, :LUNATONE, :SOLROCK,
    :CASTFORM, :SHUPPET, :BANETTE, :DUSKULL, :CHIMECHO, :GLALIE,
    :DEOXYS,
    # Gen 4+
    :BRONZOR, :BRONZONG, :DRIFLOON, :DRIFBLIM, :CHINGLING,
    :SPIRITOMB, :CARNIVINE, :ROTOM, :UXIE, :MESPRIT, :AZELF,
    :GIRATINA, :CRESSELIA, :DARKRAI,
    :YAMASK, :SIGILYPH, :SOLOSIS, :DUOSION, :REUNICLUS, :VANILLITE,
    :VANILLISH, :VANILLUXE, :EMOLGA, :TYNAMO, :EELEKTRIK, :EELEKTROSS,
    :CRYOGONAL, :HYDREIGON, :VOLCARONA,
    :VIKAVOLT, :CUTIEFLY, :RIBOMBEE, :COMFEY, :DHELMISE, :LUNALA,
    :NIHILEGO, :CELESTEELA, :KARTANA, :XURKITREE, :PHEROMOSA
  ]
  
  # List of levitating abilities
  levitating_abilities = [:LEVITATE, :AIRLOCK, :MAGNETRISE, :TELEPATHY]
  
  # Check if the Pokémon belongs to the list of levitating species or has a corresponding ability
  # FLYING Pokémon are NO longer automatically considered levitating
  return levitating_species.include?(pokemon.species) ||
         levitating_abilities.include?(pokemon.ability.id)
end

# Helper function to check if a tile is water
def is_water_tile?(x, y)
  return false if !$game_map
  
  # Check terrain tag
  terrain_tag = $game_map.terrain_tag(x, y)
  
  # Terrain tags for water are usually: 5 (deep water), 6 (shallow water), 7 (waterfall)
  return [5, 6, 7].include?(terrain_tag)
end

# Helper function to find water tiles on the map
def find_water_tiles(map_id = nil)
  map_id = $game_map.map_id if !map_id
  water_tiles = []
  
  # Scan the entire map for water tiles
  width = $game_map.width
  height = $game_map.height
  
  for x in 0...width
    for y in 0...height
      if is_water_tile?(x, y)
        water_tiles.push([x, y])
      end
    end
  end
  
  return water_tiles
end

# Helper function to find land tiles on the map
def find_land_tiles(map_id = nil)
  map_id = $game_map.map_id if !map_id
  land_tiles = []
  
  # Scan the entire map for land tiles (not water, passable)
  width = $game_map.width
  height = $game_map.height
  
  for x in 0...width
    for y in 0...height
      # Check if it's not water and passable
      if !is_water_tile?(x, y) && $game_map.passable?(x, y, 0)
        land_tiles.push([x, y])
      end
    end
  end
  
  return land_tiles
end

# Helper function to play the Pokémon's cry
def play_pokemon_cry(pokemon, volume=90)
  return if !pokemon
  
  if pokemon.is_a?(Pokemon)
    if !pokemon.egg?
      GameData::Species.play_cry_from_pokemon(pokemon, volume)
    end
  else
    form = 0
    GameData::Species.play_cry_from_species(pokemon, form, volume)
  end
end

class BoxRanch
  attr_reader :pokemon_events  # Add access to pokemon_events

  def initialize
    @pokemon_events = {}  # Event ID => Pokemon
    @map_id = 117         # Ranch map ID
    @water_tiles = []     # List of water tiles
    @land_tiles = []      # List of land tiles
  end

  def setup
    # Check the current map ID
    current_map_id = $game_map.map_id
    
    # Only call setup_ranch_pokemon if the map ID is correct
    setup_ranch_pokemon if current_map_id == @map_id
  end

  def setup_ranch_pokemon
    return if $game_map.map_id != @map_id
    
    # First, delete all existing events
    clear_ranch_pokemon
    
    # Then identify the water and land tiles
    @water_tiles = find_water_tiles
    @land_tiles = find_land_tiles
    
    # Then load all Pokémon from the box
    pokemon_list = []
    
    for i in 0...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        pkmn = $PokemonStorage[i,j]
        if pkmn
          pokemon_list.push(pkmn)
        end
      end
    end
    
    # Always create a test Pokémon (if none are available)
    if pokemon_list.empty?
      test_pokemon = Pokemon.new(:PIKACHU, 5)
      pokemon_list.push(test_pokemon)
      
      # Also add a water Pokémon
      if !@water_tiles.empty?
        water_test = Pokemon.new(:MAGIKARP, 5)
        pokemon_list.push(water_test)
      end
    end
    
    # Sort Pokémon into water and land Pokémon
    water_pokemon = []
    land_pokemon = []
    
    pokemon_list.each do |pkmn|
      if is_water_pokemon?(pkmn) && !@water_tiles.empty?
        water_pokemon.push(pkmn)
      else
        land_pokemon.push(pkmn)
      end
    end
    
    # Create events for land Pokémon
    max_land = [land_pokemon.size, 8].min
    land_pokemon[0...max_land].each_with_index do |pkmn, index|
      create_pokemon_event(pkmn, index, false)
    end
    
    # Create events for water Pokémon
    max_water = [water_pokemon.size, 5].min
    water_pokemon[0...max_water].each_with_index do |pkmn, index|
      create_pokemon_event(pkmn, index, true)
    end
    
    # Update sprites
    $scene.disposeSpritesets
    $scene.createSpritesets
  end

  def create_pokemon_event(pkmn, index, in_water = false)
    # Determine position based on water/land
    x = 0
    y = 0
    
    if in_water
      # Choose a random position from the water tiles
      if !@water_tiles.empty?
        pos = @water_tiles.sample
        x, y = pos
        # Remove the position to prevent multiple Pokémon from being at the same location
        @water_tiles.delete(pos)
      else
        # Fallback: Grid positioning as before
        ranch_area = {
          x_start: 30, y_start: 30, width: 15, height: 15, columns: 3, rows: 4
        }
        
        column = index % ranch_area[:columns]
        row = (index / ranch_area[:columns]) % ranch_area[:rows]
        
        cell_width = ranch_area[:width] / ranch_area[:columns]
        cell_height = ranch_area[:height] / ranch_area[:rows]
        
        x = ranch_area[:x_start] + (column * cell_width) + rand(cell_width / 2)
        y = ranch_area[:y_start] + (row * cell_height) + rand(cell_height / 2)
      end
    else
      # For land Pokémon
      if !@land_tiles.empty?
        # Choose a random land tile
        pos = @land_tiles.sample
        x, y = pos
        # Remove the position
        @land_tiles.delete(pos)
      else
        # Fallback: Grid positioning
        ranch_area = {
          x_start: 30, y_start: 30, width: 15, height: 15, columns: 3, rows: 4
        }
        
        column = index % ranch_area[:columns]
        row = (index / ranch_area[:columns]) % ranch_area[:rows]
        
        cell_width = ranch_area[:width] / ranch_area[:columns]
        cell_height = ranch_area[:height] / ranch_area[:rows]
        
        x = ranch_area[:x_start] + (column * cell_width) + rand(cell_width / 2)
        y = ranch_area[:y_start] + (row * cell_height) + rand(cell_height / 2)
      end
    end
    
    # Check if the Pokémon can levitate
    levitates = is_levitating_pokemon?(pkmn)
    
    # Determine sprite name
    species_name = pkmn.species.to_s
    form = pkmn.form || 0
    gender = pkmn.gender
    shiny = pkmn.shiny?
    
    # Try to get the correct sprite considering water/levitates
    sprite_path = box_ranch_sprite_filename(pkmn.species, form, gender, shiny, in_water, levitates)
    sprite_name = sprite_path.gsub("Graphics/Characters/", "")
    
    # Create event
    event = RPG::Event.new(x, y)
    event.id = $game_map.events.keys.max + 1 rescue 1
    
    # Set event name so the Overworld Shadows Plugin can recognize certain events
    # For Pokémon in water, we add a special name to prevent shadows from being displayed
    if in_water
      event.name = "InWater_Pokemon_#{pkmn.species}"
    else
      event.name = "Pokemon_#{pkmn.species}"
    end
    
    # Set graphic
    event.pages[0].graphic.character_name = sprite_name
    event.pages[0].graphic.character_hue = 0
    event.pages[0].graphic.direction = 2  # Down
    
    # Simple settings for reliable display
    event.pages[0].through = false       # Cannot be walked through
    event.pages[0].always_on_top = false # NOT always on top to look natural
    event.pages[0].step_anime = true     # Animation while standing
    event.pages[0].trigger = 0           # Action button (0 = interaction only when pressing A)
    
    # Add movement settings
    event.pages[0].move_type = 1        # 1 = Random movement
    
    # Calculate nature-dependent speed and frequency
    # Convert nature.id (symbol) to an integer value for calculation
    nature_value = pkmn.nature.id.to_s.hash.abs
    
    # Water Pokémon move slower in water
    if in_water
      event.pages[0].move_speed = 2 + (nature_value % 3)       # Values between 2-4 (slower)
    else
      event.pages[0].move_speed = 2 + (nature_value % 5)       # Values between 2-6
    end
    
    event.pages[0].move_frequency = 2 + (nature_value % 3)   # Values between 2-4
    
    # Settings for autonomous movement
    event.pages[0].move_route = RPG::MoveRoute.new
    event.pages[0].move_route.repeat = true
    event.pages[0].move_route.skippable = false
    event.pages[0].move_route.list = []
    
    # Event commands
    event.pages[0].list = []  # Empty list
    
    # Now add commands
    # Play the Pokémon's cry - use symbol notation
    Compiler::push_script(event.pages[0].list, "play_pokemon_cry(:#{pkmn.species}, 100)")
    
    # Display information
    Compiler::push_script(event.pages[0].list, "pbMessage(\"#{pkmn.name} looks at you friendly!\")")
    
    # More interactive details
    if pkmn.shiny?
      Compiler::push_script(event.pages[0].list, "pbMessage(\"#{pkmn.name} shines brightly in the sunlight.\")")
    end
    
    # Character info based on nature
    nature_text = get_nature_text(pkmn.nature)
    Compiler::push_script(event.pages[0].list, "pbMessage(\"#{nature_text}\")")
    
    # Special messages based on environment
    if in_water
      Compiler::push_script(event.pages[0].list, "pbMessage(\"It swims happily in the water!\")")
    elsif levitates
      Compiler::push_script(event.pages[0].list, "pbMessage(\"It floats elegantly in the air!\")")
    end
    
    # Level and other details
    Compiler::push_script(event.pages[0].list, "pbMessage(\"Level: #{pkmn.level}\\nAbility: #{pkmn.ability.name}\")")
    
    # Optional: Show menu - use symbol notation and pass event_id
    Compiler::push_script(event.pages[0].list, "show_pokemon_interaction_menu(:#{pkmn.species}, #{pkmn.level}, #{event.id})")
    
    Compiler::push_end(event.pages[0].list)
    
    # Add event to map
    game_event = Game_Event.new($game_map.map_id, event)
    
    # Set position directly
    game_event.moveto(x, y)
    
    # Start the event's movement
    game_event.refresh
    
    $game_map.events[event.id] = game_event
    
    # Save Pokémon reference
    @pokemon_events[event.id] = pkmn
    
    return game_event
  end

  def clear_ranch_pokemon
    event_ids_to_remove = []
    
    @pokemon_events.each_key do |event_id|
      event_ids_to_remove.push(event_id)
    end
    
    event_ids_to_remove.each do |event_id|
      if $game_map.events[event_id]
        $game_map.events.delete(event_id)
      end
    end
    
    @pokemon_events.clear
    
    # Update sprites
    $scene.disposeSpritesets
    $scene.createSpritesets
  end

  def update
    # No update needed, as the events update themselves
  end
  
  private
  
  # Helper method for nature-dependent text
  def get_nature_text(nature)
    # Descriptions for different natures
    nature_texts = {
      # Jolly natures
      :JOLLY => "It dances around happily.",
      :NAIVE => "It is very playful.",
      :HASTY => "It can't stand still and runs around constantly.",
      # Calm natures
      :CALM => "It rests peacefully.",
      :CAREFUL => "It observes its surroundings attentively.",
      :QUIET => "It enjoys the tranquility of the ranch.",
      # Aggressive natures
      :BRAVE => "It shows off bravely.",
      :ADAMANT => "It trains its muscles.",
      :NAUGHTY => "It seems to be up to something."
    }
    
    # Default text if nature is not defined
    return nature_texts[nature.id] || "It feels very comfortable on the ranch."
  end

  def create_pokemon_event_at(pkmn, x, y, in_water = false)
    # Check if the Pokémon can levitate
    levitates = is_levitating_pokemon?(pkmn)
    
    # Determine sprite name
    species_name = pkmn.species.to_s
    form = pkmn.form || 0
    gender = pkmn.gender
    shiny = pkmn.shiny?
    
    # Try to get the correct sprite considering water/levitates
    sprite_path = box_ranch_sprite_filename(pkmn.species, form, gender