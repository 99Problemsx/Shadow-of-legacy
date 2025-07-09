module PauseMenu
  # Lade alle benötigten Dateien für das Smartphone-Menü
  FILES = [
    "SmartphoneMenu",
    "MenuOverride"
  ]
  
  # Lade alle Dateien
  FILES.each do |filename|
    require_relative filename
  end
end 