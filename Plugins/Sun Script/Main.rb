#===============================================================================
# SCRIPT DE RAYO DE SOL - CREATED BY POLECTRON
#===============================================================================
# * Settings
#===============================================================================
module SunSettings
  BGPATH = "Graphics/Fogs/sun.png" # Make sure the path and file extension are correct
  UPDATESPERSECONDS = 5
end

#===============================================================================
# * Main
#===============================================================================
class Spriteset_Map
  include SunSettings

  alias :initializeSun :initialize
  alias :updateOldSun :update
  alias :disposeOldSun :dispose

  def initialize(*args)
    @sun = []
    @last_weather = :None
    @sun_timer = 0
    @last_map_id = 0
    initializeSun(*args)
    $sun_need_refresh = true
    $sun_switch = true
  end

  def dispose
    disposeSun
    disposeOldSun
  end

  def update
    updateOldSun
    updateSun
  end

  #===============================================================================
  # * HUD Data
  #===============================================================================
  def createSun
    disposeSun # First ensure any existing sun is properly disposed
    
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)

    # Ensure map_metadata exists and contains outdoor_map
    if map_metadata && map_metadata.outdoor_map
      @hideSun = PBDayNight.isNight? || !$sun_switch || !map_metadata.outdoor_map
      @correctWeather = $game_screen.weather_type == :None

      return if @hideSun || !@correctWeather || $game_map.fog_name != ""
      
      #===============================================================================
      # * Image
      #===============================================================================
      if BGPATH != "" && @viewport1 # Ensure the path is not empty and viewport exists
        begin
          bgbar = IconSprite.new(0, 0, @viewport1)
          if !pbResolveBitmap(BGPATH).nil?
            bgbar.setBitmap(BGPATH)
            bgbar.z = 999 # Reduced z value to ensure it doesn't overlay important UI
            bgbar.blend_type = 1
            
            # Center the sun sprite in the screen with fixed position
            bgbar.ox = bgbar.bitmap.width / 2
            bgbar.oy = bgbar.bitmap.height / 2
            bgbar.x = Graphics.width / 2
            bgbar.y = Graphics.height / 2
            
            # Set initial opacity based on time
            bgbar.opacity = calculateSunAlpha
            
            @sun.push(bgbar)
          end
        rescue => e
          # Safety in case of errors with the sprite
          console.log("Sun sprite error: #{e.message}")
        end
      end
    else
      @hideSun = true
    end
  end

  def updateSun
    # Check for map change
    if @last_map_id != $game_map.map_id
      disposeSun
      $sun_need_refresh = true
      @last_map_id = $game_map.map_id
    end
    
    # Check if weather has changed
    current_weather = $game_screen.weather_type
    if @last_weather != current_weather
      disposeSun
      $sun_need_refresh = true
      @last_weather = current_weather
    end
    
    # Throttle updates to prevent flickering
    @sun_timer += 1
    return unless @sun_timer >= 10
    @sun_timer = 0
    
    # Check if we need to create sun
    if @sun.empty? && shouldShowSun?
      createSun
      return
    end

    # Update existing sun sprites
    sun_alpha = calculateSunAlpha    
    @sun.each do |sprite|
      next if !sprite || sprite.disposed?
      sprite.opacity = sun_alpha
      
      # Keep sun centered on screen regardless of camera position
      sprite.x = Graphics.width / 2
      sprite.y = Graphics.height / 2
      
      sprite.update
    end

    # Check conditions for hiding the sun
    if !shouldShowSun? || sun_alpha == 0
      disposeSun unless @sun.empty?
    end
  end
  
  # Check if sun should be visible based on all conditions
  def shouldShowSun?
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    return false unless map_metadata && map_metadata.outdoor_map
    return false if PBDayNight.isNight? || !$sun_switch
    return false if $game_screen.weather_type != :None
    return false if $game_map.fog_name != ""
    return true
  end

  def disposeSun
    @sun.each do |sprite|
      sprite.dispose if sprite && !sprite.disposed?
    end
    @sun.clear
  end

  # Calculate the alpha value based on the time of day
  def calculateSunAlpha
    current_time = pbGetTimeNow
    hour = current_time.hour
    alpha = 255

    if hour >= 6 && hour <= 18
      # Full visibility during the day
      alpha = 255
    elsif hour > 18 && hour <= 20
      # Gradually fade out between 6 PM and 8 PM
      alpha = 255 - ((hour - 18) * 127.5).to_i
    elsif hour >= 4 && hour < 6
      # Gradually become visible between 4 AM and 6 AM
      alpha = ((hour - 4) * 127.5).to_i
    else
      # Invisible at night
      alpha = 0
    end

    return alpha
  end
end

#===============================================================================

class Scene_Map
  include SunSettings

  alias :updateOldSun :update
  alias :miniupdateOldSun :miniupdate
  alias :createSpritesetsOldSun :createSpritesets

  UPDATERATE = (UPDATESPERSECONDS > 0) ? 
               (Graphics.frame_rate / UPDATESPERSECONDS).floor : 0x3FFF

  def update
    updateOldSun
    checkAndUpdateSun
  end

  def miniupdate
    miniupdateOldSun
    checkAndUpdateSun
  end

  def createSpritesets
    createSpritesetsOldSun
    checkAndUpdateSun
  end

  def checkAndUpdateSun
    if $sun_need_refresh
      @spritesets.each_value do |s|
        if s.is_a?(Spriteset_Map)
          s.disposeSun
          s.createSun
        end
      end
      $sun_need_refresh = false
    end
  end
end