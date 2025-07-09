class SmartphoneMenu
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    create_background
    create_phone_frame
    create_app_buttons
    create_time_display
    @active = true
  end

  def create_background
    @background = Sprite.new(@viewport)
    @background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @background.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 128))
  end

  def create_phone_frame
    @phone_frame = Sprite.new(@viewport)
    @phone_frame.bitmap = Bitmap.new("Graphics/UI/smartphone_frame")
    @phone_frame.x = (Graphics.width - @phone_frame.bitmap.width) / 2
    @phone_frame.y = (Graphics.height - @phone_frame.bitmap.height) / 2
  rescue
    # Fallback wenn die Smartphone-Grafik nicht gefunden wurde
    @phone_frame = Sprite.new(@viewport)
    @phone_frame.bitmap = Bitmap.new(400, 600)
    @phone_frame.bitmap.fill_rect(0, 0, 400, 600, Color.new(40, 40, 40))
    @phone_frame.bitmap.fill_rect(10, 10, 380, 580, Color.new(20, 20, 20))
    @phone_frame.x = (Graphics.width - 400) / 2
    @phone_frame.y = (Graphics.height - 600) / 2
  end

  def create_app_buttons
    @buttons = []
    app_data = [
      { icon: "pokemon", text: "Pokemon", action: :open_party },
      { icon: "bag", text: "Tasche", action: :open_bag },
      { icon: "trainer", text: "Trainer", action: :open_trainer_card },
      { icon: "save", text: "Speichern", action: :save_game },
      { icon: "options", text: "Optionen", action: :open_options },
      { icon: "pokedex", text: "Pokédex", action: :open_pokedex },
      { icon: "map", text: "Karte", action: :open_map },
      { icon: "exit", text: "Zurück", action: :close_menu }
    ]
    
    grid_size = 4  # 4x2 Grid
    icon_size = 48
    padding = 20
    start_x = @phone_frame.x + 40
    start_y = @phone_frame.y + 80

    app_data.each_with_index do |app, index|
      row = index / grid_size
      col = index % grid_size
      
      x = start_x + (col * (icon_size + padding))
      y = start_y + (row * (icon_size + padding + 20))
      
      create_app_button(x, y, app[:icon], app[:text], app[:action])
    end
  end

  def create_app_button(x, y, icon_name, text, action)
    button = Sprite.new(@viewport)
    begin
      button.bitmap = Bitmap.new("Graphics/UI/smartphone_icons/#{icon_name}")
    rescue
      # Fallback wenn das Icon nicht gefunden wurde
      button.bitmap = create_fallback_icon(text[0])
    end
    button.x = x
    button.y = y
    
    # Text unter dem Icon
    text_sprite = Sprite.new(@viewport)
    text_sprite.bitmap = Bitmap.new(48, 20)
    text_sprite.bitmap.font.size = 16
    text_sprite.bitmap.font.color = Color.new(255, 255, 255)
    text_sprite.bitmap.draw_text(0, 0, 48, 20, text, 1)
    text_sprite.x = x
    text_sprite.y = y + 50
    
    @buttons.push({ sprite: button, text: text_sprite, action: action })
  end

  def create_fallback_icon(letter)
    bitmap = Bitmap.new(48, 48)
    bitmap.fill_rect(0, 0, 48, 48, Color.new(60, 60, 60))
    bitmap.font.size = 24
    bitmap.font.color = Color.new(255, 255, 255)
    bitmap.draw_text(0, 0, 48, 48, letter, 1)
    return bitmap
  end

  def create_time_display
    @time_display = Sprite.new(@viewport)
    @time_display.bitmap = Bitmap.new(100, 20)
    @time_display.x = @phone_frame.x + 40
    @time_display.y = @phone_frame.y + 30
    update_time_display
  end

  def update_time_display
    @time_display.bitmap.clear
    time = Time.now
    time_str = sprintf("%02d:%02d", time.hour, time.min)
    @time_display.bitmap.font.color = Color.new(255, 255, 255)
    @time_display.bitmap.draw_text(0, 0, 100, 20, time_str, 0)
  end

  def update
    return unless @active
    update_time_display
    
    # Mausklick oder Enter-Taste
    if Input.trigger?(Input::C) || Mouse.click?
      check_button_press
    end
    
    # ESC oder B-Taste zum Schließen
    if Input.trigger?(Input::B)
      close_menu
    end
  end

  def check_button_press
    mouse_x = Mouse.x rescue Input.mouse_x
    mouse_y = Mouse.y rescue Input.mouse_y
    
    @buttons.each do |button|
      if mouse_in_button?(button[:sprite], mouse_x, mouse_y)
        handle_action(button[:action])
        return
      end
    end
  end

  def mouse_in_button?(sprite, mouse_x, mouse_y)
    return mouse_x >= sprite.x && mouse_x < sprite.x + sprite.bitmap.width &&
           mouse_y >= sprite.y && mouse_y < sprite.y + sprite.bitmap.height
  end

  def handle_action(action)
    case action
    when :open_party
      pbFadeOutIn { pbParty }
    when :open_bag
      pbFadeOutIn { pbBag }
    when :open_trainer_card
      pbFadeOutIn { pbTrainerCard }
    when :save_game
      pbSaveScreen
    when :open_options
      pbFadeOutIn { pbOptions }
    when :open_pokedex
      pbFadeOutIn { pbPokedex }
    when :open_map
      pbFadeOutIn { pbShowMap }
    when :close_menu
      close_menu
    end
  end

  def close_menu
    @active = false
    dispose
  end

  def dispose
    @background.dispose
    @phone_frame.dispose
    @time_display.dispose
    @buttons.each do |button|
      button[:sprite].dispose
      button[:text].dispose
    end
    @viewport.dispose
  end
end 