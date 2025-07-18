#-------------------------------------------------------------------------------
# Monotype and Randomizer Mode Implementation
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Monotype Mode - Block catching/receiving invalid Pokemon
#-------------------------------------------------------------------------------
EventHandlers.add(:on_pokemon_received, :monotype_check,
  proc { |sender, e|
    pokemon = e[0]
    next if !ChallengeModes.on?(:MONOTYPE_MODE)
    next if ChallengeModes.valid_monotype_pokemon?(pokemon)
    
    type_name = GameData::Type.get($PokemonGlobal.challenge_monotype_type).name
    species_name = pokemon.species_data.name
    pbMessage(_INTL("The Monotype challenge prevents you from using {1}! You can only use {2}-type Pokémon.", species_name, type_name))
    e[0] = nil  # Cancel the Pokemon reception
  }
)

# Block using invalid Pokemon in battle for Monotype
class Battle
  alias __monotype__pbCanSwitchIn? pbCanSwitchIn? unless method_defined?(:__monotype__pbCanSwitchIn?)
  def pbCanSwitchIn?(idxBattler, idxParty, partyScene = nil)
    return false if !__monotype__pbCanSwitchIn?(idxBattler, idxParty, partyScene)
    
    if ChallengeModes.on?(:MONOTYPE_MODE)
      pokemon = @sides[idxBattler].party[idxParty]
      if pokemon && !ChallengeModes.valid_monotype_pokemon?(pokemon)
        return false
      end
    end
    
    return true
  end
end

#-------------------------------------------------------------------------------
# Randomizer Mode - Wild Pokemon encounters
#-------------------------------------------------------------------------------
EventHandlers.add(:on_wild_species_chosen, :randomizer_wild,
  proc { |encounter|
    next if !ChallengeModes.on?(:RANDOMIZER_MODE)
    next if !ChallengeModes::RANDOMIZER_SETTINGS[:wild_pokemon]
    next if !encounter
    
    original_species = encounter[0]
    level = encounter[1] || 1
    
    # The encounter[0] should be a species symbol, but let's handle both cases
    begin
      species_data = GameData::Species.get(original_species)
    rescue
      # If it fails, it might be an integer ID that we need to convert
      Console.echo_warn("Randomizer: Received unexpected species format: #{original_species.class} - #{original_species}")
      next
    end
    
    is_legendary = species_data.has_flag?("Legendary") || species_data.has_flag?("Mythical")
    
    randomized_species = ChallengeModes.get_randomized_species(original_species, is_legendary, level)
    encounter[0] = randomized_species
  }
)

#-------------------------------------------------------------------------------
# Randomizer Mode - Starter Pokemon
#-------------------------------------------------------------------------------
# NOTE: Starter Pokemon are handled automatically through the pbAddPokemon hook
# when the gift_pokemon setting is enabled, so no special handling is needed here.

#-------------------------------------------------------------------------------
# Randomizer Mode - Gift Pokemon
#-------------------------------------------------------------------------------
alias __randomizer__pbAddPokemon pbAddPokemon unless defined?(__randomizer__pbAddPokemon)
def pbAddPokemon(*args)
  if ChallengeModes.on?(:RANDOMIZER_MODE) && ChallengeModes::RANDOMIZER_SETTINGS[:gift_pokemon]
    pkmn = args[0]
    level = args[1] || 1
    
    if pkmn.is_a?(Symbol) || pkmn.is_a?(String)
      # It's a species symbol/string, randomize it
      original_species = pkmn
      species_data = GameData::Species.get(original_species)
      is_legendary = species_data.has_flag?("Legendary") || species_data.has_flag?("Mythical")
      randomized_species = ChallengeModes.get_randomized_species(original_species, is_legendary, level)
      args[0] = randomized_species
    elsif pkmn.is_a?(Pokemon)
      # It's already a Pokemon object, randomize its species
      original_species = pkmn.species
      species_data = pkmn.species_data
      is_legendary = species_data.has_flag?("Legendary") || species_data.has_flag?("Mythical")
      randomized_species = ChallengeModes.get_randomized_species(original_species, is_legendary, pkmn.level)
      
      if randomized_species != original_species
        # Create new Pokemon with randomized species but keep other properties
        new_pokemon = Pokemon.new(randomized_species, pkmn.level)
        new_pokemon.form = pkmn.form if new_pokemon.species_data.forms.length > pkmn.form
        new_pokemon.shiny = pkmn.shiny?
        new_pokemon.iv = pkmn.iv.clone
        new_pokemon.ev = pkmn.ev.clone
        new_pokemon.moves = pkmn.moves.clone
        new_pokemon.item = pkmn.item
        new_pokemon.ability_index = pkmn.ability_index
        new_pokemon.nature = pkmn.nature
        new_pokemon.happiness = pkmn.happiness
        args[0] = new_pokemon
      end
    end
  end
  
  return __randomizer__pbAddPokemon(*args)
end

#-------------------------------------------------------------------------------
# Randomizer Mode - Trainer Pokemon (simplified approach)
#-------------------------------------------------------------------------------
class Battle
  alias __randomizer__pbLoadTrainer pbLoadTrainer unless method_defined?(:__randomizer__pbLoadTrainer)
  def pbLoadTrainer(*args)
    ret = __randomizer__pbLoadTrainer(*args)
    
    if ChallengeModes.on?(:RANDOMIZER_MODE) && ChallengeModes::RANDOMIZER_SETTINGS[:trainer_pokemon]
      # Randomize trainer Pokemon after loading
      @opponent.each do |trainer|
        trainer.party.each do |pokemon|
          original_species = pokemon.species
          species_data = pokemon.species_data
          is_legendary = species_data.has_flag?("Legendary") || species_data.has_flag?("Mythical")
          randomized_species = ChallengeModes.get_randomized_species(original_species, is_legendary, pokemon.level)
          
          if randomized_species != original_species
            pokemon.species = randomized_species
            pokemon.calc_stats
          end
        end
      end
    end
    
    return ret
  end
end

#-------------------------------------------------------------------------------
# Reset challenge data including new modes
#-------------------------------------------------------------------------------
module ChallengeModes
  alias __new_modes__reset reset unless method_defined?(:__new_modes__reset)
  def reset
    __new_modes__reset
    return if !$PokemonGlobal
    $PokemonGlobal.challenge_monotype_type = nil
    $PokemonGlobal.challenge_randomizer_seed = nil
    $PokemonGlobal.challenge_randomizer_map = nil
  end
end 