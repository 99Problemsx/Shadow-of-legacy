class Scene_Map
  alias old_update update
  def update
    if Input.trigger?(Input::X)  # X-Taste öffnet das Smartphone-Menü
      open_smartphone_menu
      return
    end
    old_update
  rescue => e
    Console.echo_error(e) if $DEBUG
    old_update
  end

  def open_smartphone_menu
    begin
      menu = SmartphoneMenu.new
      loop do
        Graphics.update
        Input.update
        menu.update
        break if !menu || !menu.instance_variable_get(:@active)
      end
    rescue => e
      Console.echo_error(e) if $DEBUG
    ensure
      menu.dispose if menu && !menu.disposed?
    end
  end
end 