class Battle::Scene
  MESSAGE_BASE_COLOR   = Color.new(255, 255, 255)
  MESSAGE_SHADOW_COLOR = Color.new(32, 32, 32)
end

class Battle::Scene::PokemonDataBox < Sprite
  NAME_BASE_COLOR         = Color.new(255, 255, 255)
  NAME_BORDER_COLOR       = Color.new(32,32,32)
  MALE_BASE_COLOR         = Color.new(48, 96, 216)
  MALE_BORDER_COLOR       = NAME_BORDER_COLOR
  FEMALE_BASE_COLOR       = Color.new(248, 88, 40)
  FEMALE_BORDER_COLOR     = NAME_BORDER_COLOR
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = @battler.index.even?
    if $game_switches[999]   # Check if switch 999 is ON
      bgFilename = [_INTL("Graphics/UI/Battle/databox_special"),
                    _INTL("Graphics/UI/Battle/databox_special_foe")][@battler.index % 2]
      @databoxBitmap&.dispose
      @databoxBitmap = AnimatedBitmap.new(bgFilename)
      
      if onPlayerSide
        @show_hp_numbers = true
        @show_exp_bar    = true
        @spriteX = Graphics.width - 244
        @spriteY = Graphics.height - 192
        @spriteBaseX = 34
      else
        @spriteX = (Graphics.width - @databoxBitmap.width) / 2
        @spriteY = 14
        @spriteBaseX = (@databoxBitmap.width - 180) / 2
      end
      
      @hpBarWidth = 132
      
      case sideSize
      when 2
        @spriteX += [-12,  12,  0,  0][@battler.index]
        @spriteY += [-20, -34, 34, 20][@battler.index]
      when 3
        @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
        @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
      end
    else
      if sideSize == 1
        bgFilename = [_INTL("Graphics/UI/Battle/databox_normal"),
                      _INTL("Graphics/UI/Battle/databox_normal_foe")][@battler.index % 2]
      else
        bgFilename = [_INTL("Graphics/UI/Battle/databox_thin"),
                      _INTL("Graphics/UI/Battle/databox_thin_foe")][@battler.index % 2]
      end
      
      @databoxBitmap&.dispose
      @databoxBitmap = AnimatedBitmap.new(bgFilename)
      
      if onPlayerSide
        @show_hp_numbers = true
        @show_exp_bar    = true
        @spriteX = Graphics.width - 244
        @spriteY = Graphics.height - 192
        @spriteBaseX = 34
      else
        @spriteX = -16
        @spriteY = 36
        @spriteBaseX = 16
      end
      
      @hpBarWidth = 78
      
      case sideSize
      when 2
        @spriteX += [-12,  12,  0,  0][@battler.index]
        @spriteY += [-20, -34, 34, 20][@battler.index]
      when 3
        @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
        @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
      end
    end
  end
  
  def initializeOtherGraphics(viewport)
    @numbersBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers")
    
    # Always use normal HP bar since Switch 999 is disabled
    @hpBarBitmap = AnimatedBitmap.new("Graphics/UI/Battle/overlay_hp")
    
    @expBarBitmap  = AnimatedBitmap.new("Graphics/UI/Battle/overlay_exp")
    
    @hpNumbers = BitmapSprite.new(124, 16, viewport)
    @sprites["hpNumbers"] = @hpNumbers
    
    @hpBar = Sprite.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height / 3
    @sprites["hpBar"] = @hpBar
    
    @expBar = Sprite.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    
    @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150 + ((@battler.index / 2) * 5)
    pbSetSystemFont(self.bitmap)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
    @contents.dispose
    super
  end
  
def x=(value)
  super
  # Always use normal HP bar positioning since Switch 999 is disabled
  @hpBar.x = value + @spriteBaseX + 102
  @expBar.x    = value + @spriteBaseX + 6
  @hpNumbers.x = value + @spriteBaseX + 80
end
  
  def y=(value)
    super
    @hpBar.y     = value + 40
    @expBar.y    = value + 74
    @hpNumbers.y = value + 52
  end
  
  def z=(value)
    super
    @hpBar.z     = value + 1
    @expBar.z    = value + 1
    @hpNumbers.z = value + 2
  end
  
  def opacity=(value)
    super
    @sprites.each do |i|
      i[1].opacity = value if !i[1].disposed?
    end
  end
  
  def visible=(value)
    super
    @sprites.each do |i|
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @show_exp_bar)
  end
  
  def color=(value)
    super
    @sprites.each do |i|
      i[1].color = value if !i[1].disposed?
    end
  end
  
  def battler=(b)
    @battler = b
    self.visible = (@battler && !@battler.fainted?)
  end
  
  def hp
    return (animating_hp?) ? @anim_hp_current : @battler.hp
  end
  
  def exp_fraction
    if animating_exp?
      return 0.0 if @anim_exp_range == 0
      return @anim_exp_current.to_f / @anim_exp_range
    end
    return @battler.pokemon.exp_fraction
  end
  def animate_hp(old_val, new_val)
    return if old_val == new_val
    @anim_hp_start = old_val
    @anim_hp_end = new_val
    @anim_hp_current = old_val
    @anim_hp_timer_start = System.uptime
  end

  def animating_hp?
    return @anim_hp_timer_start != nil
  end

  def animate_exp(old_val, new_val, range)
    return if old_val == new_val || range == 0 || !@show_exp_bar
    @anim_exp_start = old_val
    @anim_exp_end = new_val
    @anim_exp_range = range
    @anim_exp_duration_mult = (new_val - old_val).abs / range.to_f
    @anim_exp_current = old_val
    @anim_exp_timer_start = System.uptime
    pbSEPlay("Pkmn exp gain") if @show_exp_bar
  end

  def animating_exp?
    return @anim_exp_timer_start != nil
  end

def draw_text_with_border(bitmap, text, x, y, base_color, border_color)
  offsets = [-2, -1, 0, 1, 2]
  offsets.each do |ox|
    offsets.each do |oy|
      next if ox == 0 && oy == 0
      bitmap.font.color = border_color
      bitmap.draw_text(x + ox, y + oy, bitmap.text_size(text).width, bitmap.text_size(text).height, text)
    end
  end
  bitmap.font.color = base_color
  bitmap.draw_text(x, y, bitmap.text_size(text).width, bitmap.text_size(text).height, text)
end

def pbDrawNumber(number, btmp, startX, startY, align = :left)
  n = (number == -1) ? [10] : number.to_i.digits.reverse
  charWidth  = @numbersBitmap.width / 11
  charHeight = @numbersBitmap.height
  startX -= charWidth * n.length if align == :right
  n.each do |i|
    btmp.blt(startX, startY, @numbersBitmap.bitmap, Rect.new(i * charWidth, 0, charWidth, charHeight))
    startX += charWidth
  end
end

def draw_background
  self.bitmap.blt(0, 0, @databoxBitmap.bitmap, Rect.new(0, 0, @databoxBitmap.width, @databoxBitmap.height))
end

def draw_name
  nameWidth = self.bitmap.text_size(@battler.name).width
  nameOffset = 0
  nameOffset = nameWidth - 116 if nameWidth > 116
  draw_text_with_border(self.bitmap, @battler.name, @spriteBaseX + 8 - nameOffset, 12, NAME_BASE_COLOR, NAME_BORDER_COLOR)
end

def draw_level
  pbDrawImagePositions(self.bitmap, [[_INTL("Graphics/UI/Battle/overlay_lv"), @spriteBaseX + 140, 16]])
  pbDrawNumber(@battler.level, self.bitmap, @spriteBaseX + 164, 16)
end

def draw_gender
  gender = @battler.displayGender
  return if ![0, 1].include?(gender)
  gender_text  = (gender == 0) ? _INTL("♂") : _INTL("♀")
  base_color   = (gender == 0) ? MALE_BASE_COLOR : FEMALE_BASE_COLOR
  border_color = (gender == 0) ? MALE_BORDER_COLOR : FEMALE_BORDER_COLOR
  draw_text_with_border(self.bitmap, gender_text, @spriteBaseX + 126, 12, base_color, border_color)
end

def draw_status
  return if @battler.status == :NONE
  
  if @battler.index.odd? && $game_switches[999]
    icon_x_offset = +264
  else
    icon_x_offset = 0
  end
  
  if @battler.status == :POISON && @battler.statusCount > 0
    s = GameData::Status.count - 1
  else
    s = GameData::Status.get(@battler.status).icon_position
  end
  
  return if s < 0
  

  pbDrawImagePositions(self.bitmap, [
    [
      _INTL("Graphics/UI/Battle/icon_statuses"),
      @spriteBaseX + 24 + icon_x_offset,
      36,
      0,
      s * STATUS_ICON_HEIGHT,
      -1,
      STATUS_ICON_HEIGHT
    ]
  ])
end

def draw_shiny_icon
  return if !@battler.shiny?
  shiny_x = (@battler.opposes?(0)) ? 206 : -6
  pbDrawImagePositions(self.bitmap, [["Graphics/UI/shiny", @spriteBaseX + shiny_x, 36]])
end

def draw_special_form_icon
  if @battler.mega?
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_mega", @spriteBaseX + 8, 34]])
  elsif @battler.primal?
    filename = nil
    if @battler.isSpecies?(:GROUDON)
      filename = "Graphics/UI/Battle/icon_primal_Groudon"
    elsif @battler.isSpecies?(:KYOGRE)
      filename = "Graphics/UI/Battle/icon_primal_Kyogre"
    end
    primalX = (@battler.opposes?) ? 208 : -28
    pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + primalX, 4]]) if filename
  end
end

def draw_owned_icon
  return if !@battler.owned? || !@battler.opposes?(0)
  x_position = @spriteBaseX + 8
  if $game_switches[999]  # Comprobar si el interruptor 999 está activo
    x_position -= 128
  end
  pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_own", x_position, 36]])
end


  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    draw_background
    draw_name
    draw_level
    draw_gender
    draw_status
    draw_shiny_icon
    draw_special_form_icon
    draw_owned_icon
    refresh_hp
    refresh_exp
  end

  def refresh_hp
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Mostrar los números de HP
    if @show_hp_numbers
      pbDrawNumber(self.hp, @hpNumbers.bitmap, 54, 0, :right)   # Elevado 2 píxeles
      pbDrawNumber(-1, @hpNumbers.bitmap, 54, 0)   # Caracter / elevado 2 píxeles
      pbDrawNumber(@battler.totalhp, @hpNumbers.bitmap, 70, 0)   # Elevado 2 píxeles
    end
    # Redimensionar la barra de HP
    w = 0
    if self.hp > 0
      w = @hpBarBitmap.width.to_f * self.hp / @battler.totalhp
      w = 1 if w < 1
      # Ajustar el ancho de la barra a los píxeles más cercanos
      w = w.round
    end
    @hpBar.src_rect.width = w
    hpColor = 0                                      # Barra verde
    hpColor = 1 if self.hp <= @battler.totalhp / 2   # Barra amarilla
    hpColor = 2 if self.hp <= @battler.totalhp / 4   # Barra roja
    @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
  end

  def refresh_exp
    return if !@show_exp_bar
    w = exp_fraction * @expBarBitmap.width
    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
    #       fit in with the rest of the graphics which are doubled in size.
    w = ((w / 2).round) * 2
    @expBar.src_rect.width = w
  end

  def update_hp_animation
    return if !animating_hp?
    @anim_hp_current = lerp(@anim_hp_start, @anim_hp_end, HP_BAR_CHANGE_TIME,
                            @anim_hp_timer_start, System.uptime)
    # Refresh the HP bar/numbers
    refresh_hp
    # End the HP bar filling animation
    if @anim_hp_current == @anim_hp_end
      @anim_hp_start = nil
      @anim_hp_end = nil
      @anim_hp_timer_start = nil
      @anim_hp_current = nil
    end
  end

  def update_exp_animation
    return if !animating_exp?
    if !@show_exp_bar   # Not showing the Exp bar, no need to waste time animating it
      @anim_exp_timer_start = nil
      return
    end
    duration = EXP_BAR_FILL_TIME * @anim_exp_duration_mult
    @anim_exp_current = lerp(@anim_exp_start, @anim_exp_end, duration,
                             @anim_exp_timer_start, System.uptime)
    # Refresh the Exp bar
    refresh_exp
    return if @anim_exp_current != @anim_exp_end   # Exp bar still has more to animate
    # End the Exp bar filling animation
    if @anim_exp_current >= @anim_exp_range
      if @anim_exp_flash_timer_start
        # Waiting for Exp full flash to finish
        return if System.uptime - @anim_exp_flash_timer_start < EXP_FULL_FLASH_DURATION
      else
        # Show the Exp full flash
        @anim_exp_flash_timer_start = System.uptime
        pbSEStop
        pbSEPlay("Pkmn exp full")
        flash_duration = EXP_FULL_FLASH_DURATION * Graphics.frame_rate   # Must be in frames, not seconds
        self.flash(Color.new(64, 200, 248, 192), flash_duration)
        @sprites.each do |i|
          i[1].flash(Color.new(64, 200, 248, 192), flash_duration) if !i[1].disposed?
        end
        return
      end
    end
    pbSEStop if !@anim_exp_flash_timer_start
    @anim_exp_start = nil
    @anim_exp_end = nil
    @anim_exp_duration_mult = nil
    @anim_exp_current = nil
    @anim_exp_timer_start = nil
    @anim_exp_flash_timer_start = nil
  end

  def update_positions
    self.x = @spriteX
    self.y = @spriteY
    # Data box bobbing while Pokémon is selected
    if (@selected == 1 || @selected == 2) && BOBBING_DURATION   # Choosing commands/targeted
      bob_delta = System.uptime % BOBBING_DURATION   # 0-BOBBING_DURATION
      bob_frame = (4 * bob_delta / BOBBING_DURATION).floor
      case bob_frame
      when 1 then self.y = @spriteY - 2
      when 3 then self.y = @spriteY + 2
      end
    end
  end

  def update
    super
    # Animate HP bar
    update_hp_animation
    # Animate Exp bar
    update_exp_animation
    # Update coordinates of the data box
    update_positions
    pbUpdateSpriteHash(@sprites)
  end
end

if PluginManager.installed?("Type Icons in Battle")
  class Battle::Scene::PokemonDataBox < Sprite
    def initializeOtherGraphics(viewport)
      # Create other bitmaps
      @numbersBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers")
     
      # Determine which HP bar overlay to use based on the switch state
      if @battler.index.odd? && $game_switches[999]   # Check if switch 999 is ON for odd-indexed battlers (enemies)
        @hpBarBitmap = AnimatedBitmap.new("Graphics/UI/Battle/overlay_hp_special")
      else
        @hpBarBitmap = AnimatedBitmap.new("Graphics/UI/Battle/overlay_hp")
      end
     
      @expBarBitmap  = AnimatedBitmap.new("Graphics/UI/Battle/overlay_exp")
     
      # Create sprite to draw HP numbers on
      @hpNumbers = BitmapSprite.new(124, 16, viewport)
      @sprites["hpNumbers"] = @hpNumbers
     
      # Create sprite wrapper that displays HP bar
      @hpBar = Sprite.new(viewport)
      @hpBar.bitmap = @hpBarBitmap.bitmap
      @hpBar.src_rect.height = @hpBarBitmap.height / 3
      @sprites["hpBar"] = @hpBar
     
      # Create sprite wrapper that displays Exp bar
      @expBar = Sprite.new(viewport)
      @expBar.bitmap = @expBarBitmap.bitmap
      @sprites["expBar"] = @expBar
  
      @types_x = (@battler.opposes?(0)) ? 0 : 0 # Position next to the databox
      @types_bitmap = AnimatedBitmap.new("Graphics/UI/Battle/types_ico")
      @types_sprite = Sprite.new(viewport)
      
      # For horizontal arrangement
      width = @types_bitmap.width  # Use the actual width of the types_ico
      height = @types_bitmap.height / GameData::Type.count
      
      # Calculate total width for all types horizontally (without gaps)
      total_width = @battler.types.size * width
      
      # Set Y position
      @types_y = 10
      
      # Create bitmap with horizontal size
      @types_sprite.bitmap = Bitmap.new(total_width, height)
      @types_sprite.x = @types_x
      @types_sprite.y = @types_y
   
      @sprites["types_sprite"] = @types_sprite
     
      # Create sprite wrapper that displays everything except the above
      @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height)
      self.bitmap  = @contents
      self.visible = false
      self.z       = 150 + ((@battler.index / 2) * 5)
      pbSetSystemFont(self.bitmap)
    end
   
    def dispose
      pbDisposeSpriteHash(@sprites)
      @databoxBitmap.dispose
      @numbersBitmap.dispose
      @hpBarBitmap.dispose
      @expBarBitmap.dispose
      @types_bitmap.dispose
      @contents.dispose
      super
    end
  
    def x=(value)
      super
      if @battler.index.odd? && $game_switches[999]
        @hpBar.x = value + (@databoxBitmap.width - @hpBarBitmap.width) / 2
        @types_sprite.x = value + @types_x + 259
      else
        @hpBar.x = value + @spriteBaseX + 102
        if @battler.opposes?(0)  # Enemy
          @types_sprite.x = value + @spriteBaseX + 5  # Left next to the name
        else  # Player
          @types_sprite.x = value + @spriteBaseX + 15  # Further left as before
        end
      end
      @expBar.x    = value + @spriteBaseX + 6
      @hpNumbers.x = value + @spriteBaseX + 80
    end
  
    def y=(value)
      super
      @hpBar.y     = value + 40
      @expBar.y    = value + 74
      @hpNumbers.y = value + 52
      if @battler.index.odd? && $game_switches[999]
        @types_sprite.y = value + @types_y - 3
      else
        # Position the icons next to the names
        if @battler.opposes?(0)  # Enemy
          @types_sprite.y = value + 35  # 15 pixels down (8 + 15)
        else  # Player
          @types_sprite.y = value + 40 # 20 pixels down (8 + 20)
        end
      end
    end
  
    def z=(value)
      super
      @hpBar.z     = value + 1
      @expBar.z    = value + 1
      @hpNumbers.z = value + 2
      @types_sprite.z = value + 1
    end
  
    def refresh
      self.bitmap.clear
      return if !@battler.pokemon
      draw_background
      draw_name
      draw_level
      draw_gender
      draw_status
      draw_shiny_icon
      draw_special_form_icon
      draw_owned_icon
      refresh_hp
      refresh_exp
      draw_type_icons
    end
  
    def draw_type_icons
      # Draw the Pokémon's types horizontally (side by side)
      @types_sprite.bitmap.clear
    
      # Calculate the width and height of each type  
      width  = 24  # Exact width for type icons (entire bitmap is 24 wide)
      height = 28  # Exact height for type icons (560 / 20 types = 28)
      
      # Calculate the total width for all types horizontally (without gaps)
      total_width = @battler.types.size * width
      
      # Create the bitmap with the correct width and height
      @types_sprite.bitmap.dispose if @types_sprite.bitmap
      @types_sprite.bitmap = Bitmap.new(total_width, height)
  
      @battler.types.each_with_index do |type, i|
        # Get the type object and its icon position
        type_number = GameData::Type.get(type).icon_position
        # Width and height of the icon - for types_ico format (each type is 24x28)
        type_rect = Rect.new(0, type_number * 28, 24, 28)
        # Horizontal X position (directly side by side, without gaps)
        x_position = i * width
  
        # Draw the icon horizontally
        @types_sprite.bitmap.blt(x_position, 0, @types_bitmap.bitmap, type_rect)
      end
  
      @sprites["types_sprite"] = @types_sprite
    end
  end
end
