#===============================================================================
# Window Lights Plugin - Animated Fog
# Erstellt animierte Fog-Effekte für Fensterlichter
#===============================================================================

class WindowLightsFog
  def initialize(viewport)
    @viewport = viewport
    @fog_sprites = []
    @animation_timer = 0
    create_fog_effects
  end
  
  def create_fog_effects
    return unless $game_map && $game_map.events
    
    puts "DEBUG: Erstelle Fog-Effekte für Fensterlichter..."
    
    $game_map.events.each_value do |event|
      next unless event.name && event.name.match(/licht|light|fenster|window/i)
      
      puts "DEBUG: Erstelle Fog für Event: #{event.name}"
      
      # Erstelle Fog-Sprite für dieses Event
      fog_sprite = create_fog_sprite(event)
      @fog_sprites << fog_sprite if fog_sprite
    end
    
    puts "DEBUG: #{@fog_sprites.size} Fog-Effekte erstellt"
  end
  
  def create_fog_sprite(event)
    begin
      # Erstelle Fog-Bitmap
      fog_bitmap = create_fog_bitmap
      
      # Erstelle Sprite
      sprite = Sprite.new(@viewport)
      sprite.bitmap = fog_bitmap
      sprite.blend_type = 1 # Additive blending
      sprite.z = 100
      sprite.opacity = 0
      
      # Position basierend auf Event
      sprite.x = event.screen_x - 32
      sprite.y = event.screen_y - 32
      
      # Speichere Event-Referenz für Updates
      sprite.instance_variable_set(:@event, event)
      sprite.instance_variable_set(:@base_x, sprite.x)
      sprite.instance_variable_set(:@base_y, sprite.y)
      sprite.instance_variable_set(:@animation_offset, rand(100))
      
      return sprite
    rescue => e
      puts "DEBUG: Fehler beim Erstellen des Fog-Sprites: #{e.message}"
      return nil
    end
  end
  
  def create_fog_bitmap
    size = 64
    bitmap = Bitmap.new(size, size)
    
    # Erstelle warmes Licht mit Verlauf
    center = size / 2
    (0...size).each do |x|
      (0...size).each do |y|
        distance = Math.sqrt((x - center) ** 2 + (y - center) ** 2)
        if distance <= center
          # Weicher Verlauf
          alpha = [(1.0 - distance / center) * 180, 0].max
          # Warmes gelbes Licht
          bitmap.set_pixel(x, y, Color.new(255, 255, 150, alpha))
        end
      end
    end
    
    return bitmap
  end
  
  def update
    @animation_timer += 1
    
    @fog_sprites.each do |sprite|
      next unless sprite && !sprite.disposed?
      
      # Prüfe ob Licht an sein soll
      should_show = should_show_lights?
      
      # Animiere Opacity
      if should_show
        target_opacity = 120 + Math.sin((@animation_timer + sprite.instance_variable_get(:@animation_offset)) * 0.05) * 40
        sprite.opacity = target_opacity
      else
        sprite.opacity = 0
      end
      
      # Update Position basierend auf Kamera
      event = sprite.instance_variable_get(:@event)
      if event && $game_map
        sprite.x = event.screen_x - 32
        sprite.y = event.screen_y - 32
      end
    end
  end
  
  def should_show_lights?
    # Prüfe Tageszeit
    is_night = false
    if defined?(PBDayNight) && PBDayNight.respond_to?(:isNight?)
      is_night = PBDayNight.isNight?
    elsif defined?(pbGetTimeNow)
      hour = pbGetTimeNow.hour
      is_night = hour >= 19 || hour < 6
    end
    
    # Prüfe Wetter
    weather_dark = $game_screen && ($game_screen.weather_type == :Rain || $game_screen.weather_type == :Storm)
    
    # TEMPORÄR: Immer an zum Testen
    return true
    
    return is_night || weather_dark
  end
  
  def dispose
    @fog_sprites.each do |sprite|
      next unless sprite && !sprite.disposed?
      sprite.bitmap.dispose if sprite.bitmap
      sprite.dispose
    end
    @fog_sprites.clear
  end
end

class Spriteset_Map
  alias window_lights_initialize initialize
  def initialize(map = nil)
    window_lights_initialize(map)
    
    # Erstelle Fog-Effekte nach der Initialisierung
    if @viewport1
      @window_lights_fog = WindowLightsFog.new(@viewport1)
    end
  end
  
  alias window_lights_update update
  def update
    window_lights_update
    @window_lights_fog.update if @window_lights_fog
  end
  
  alias window_lights_dispose dispose
  def dispose
    @window_lights_fog.dispose if @window_lights_fog
    window_lights_dispose
  end
end

puts "Window Lights Plugin (Animated Fog) geladen!" 