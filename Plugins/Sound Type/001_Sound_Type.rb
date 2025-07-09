#===============================================================================
# Sound Type Plugin
#===============================================================================
# This plugin adds the Sound type and makes it immune to confusion
#===============================================================================

module GameData
  class Type
    # Add Sound type to the list of special types
    SPECIAL_TYPES.push(:SOUND)
  end
end

class Battle::Battler
  # Make Sound-type Pokémon immune to confusion
  alias sound_type_can_confuse? pbCanConfuse?
  def pbCanConfuse?(*args)
    if hasType?(:SOUND)
      @battle.pbDisplay(_INTL("{1} ist immun gegen Verwirrung, da es vom Typ Sound ist!", pbThis))
      return false
    end
    return sound_type_can_confuse?(*args)
  end
end

# Add Sound type to the type effectiveness chart
module Effectiveness
  module_function

  alias sound_type_calculate calculate
  def calculate(moveType, userType, targetType1, targetType2 = nil)
    ret = sound_type_calculate(moveType, userType, targetType1, targetType2)
    # Add Sound type effectiveness
    if moveType == :SOUND
      ret = Effectiveness::NORMAL_EFFECTIVE
      ret = Effectiveness::SUPER_EFFECTIVE if [:GROUND, :ELECTRIC].include?(targetType1) || 
                                            [:GROUND, :ELECTRIC].include?(targetType2)
      ret = Effectiveness::NOT_VERY_EFFECTIVE if [:WATER, :GRASS, :FAIRY].include?(targetType1) || 
                                                [:WATER, :GRASS, :FAIRY].include?(targetType2)
      ret = Effectiveness::IMMUNE if [:PSYCHIC].include?(targetType1) || 
                                   [:PSYCHIC].include?(targetType2)
    end
    return ret
  end
end 