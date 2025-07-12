#===============================================================================
# Beispiel-Event für das Gen 2 Phone System
# Dieses Script zeigt, wie du das Telefonsystem in deinen Events verwendest
#===============================================================================

# Beispiel: Angler Klaus Event
# Dieses Event würde in einem Map-Event verwendet werden

def angler_klaus_event
  # Prüfe ob der Spieler das Pokégear hat
  if !$player.has_pokegear
    pbMessage("Hallo! Ich bin Klaus, ein Angler.")
    pbMessage("Schade, dass du kein Pokégear hast...")
    pbMessage("Sonst hätte ich dir meine Nummer gegeben!")
    return
  end
  
  # Prüfe ob Klaus bereits im Telefon ist
  if Phone.get(true, :FISHERMAN, "Klaus")
    pbMessage("Hallo wieder! Wie läuft das Angeln?")
    pbMessage("Ruf mich an, wenn du Tipps brauchst!")
    return
  end
  
  # Erste Begegnung mit Klaus
  pbMessage("Hallo! Ich bin Klaus, ein leidenschaftlicher Angler.")
  pbMessage("Ich kenne alle Geheimnisse des Angelns!")
  
  # Kampf gegen Klaus (optional)
  if pbConfirmMessage("Möchtest du gegen mich kämpfen?")
    pbTrainerBattle(:FISHERMAN, "Klaus", "Mal sehen, ob du mit meinen Wasser-Pokémon mithalten kannst!")
  end
  
  # Telefonnummer anbieten
  if Phone.can_add?(:FISHERMAN, "Klaus")
    pbMessage("Du scheinst ein vielversprechender Trainer zu sein!")
    pbMessage("Wie wäre es, wenn ich dir meine Nummer gebe?")
    
    if pbConfirmMessage("Möchtest du meine Telefonnummer?")
      # Nummer hinzufügen
      Phone.add(get_self, :FISHERMAN, "Klaus")
      pbMessage("Perfekt! Ich rufe dich an, wenn ich etwas Interessantes erlebt habe!")
      pbMessage("Vielleicht erzähle ich dir auch den einen oder anderen Angel-Tipp!")
    else
      pbMessage("Schade... Falls du es dir anders überlegst, findest du mich hier.")
    end
  end
end

# Beispiel: Youngster Tim Event
def youngster_tim_event
  if !$player.has_pokegear
    pbMessage("Hey! Ich bin Tim!")
    pbMessage("Ich trainiere jeden Tag mit meinen Pokémon!")
    pbMessage("Schade, dass du kein Pokégear hast...")
    return
  end
  
  if Phone.get(true, :YOUNGSTER, "Tim")
    pbMessage("Hey! Schön dich zu sehen!")
    pbMessage("Meine Pokémon sind seit unserem letzten Gespräch noch stärker geworden!")
    return
  end
  
  pbMessage("Hey! Ich bin Tim!")
  pbMessage("Ich liebe es, mit anderen Trainern zu kämpfen!")
  
  if pbConfirmMessage("Lust auf einen Kampf?")
    pbTrainerBattle(:YOUNGSTER, "Tim", "Ich zeige dir, wie stark meine Pokémon sind!")
  end
  
  if Phone.can_add?(:YOUNGSTER, "Tim")
    pbMessage("Du bist echt cool!")
    pbMessage("Lass uns Freunde werden!")
    
    if pbConfirmMessage("Willst du meine Nummer?")
      Phone.add(get_self, :YOUNGSTER, "Tim")
      pbMessage("Awesome! Ich rufe dich bestimmt an!")
      pbMessage("Vielleicht kann ich dir auch mal einen coolen Tipp geben!")
    else
      pbMessage("Ach komm schon... Na gut, vielleicht später!")
    end
  end
end

# Beispiel: Lass Maria Event
def lass_maria_event
  if !$player.has_pokegear
    pbMessage("Hallo! Ich bin Maria!")
    pbMessage("Meine Pokémon sind so süß!")
    pbMessage("Schade, dass du kein Pokégear hast...")
    return
  end
  
  if Phone.get(true, :LASS, "Maria")
    pbMessage("Hallo! Wie geht es deinen Pokémon?")
    pbMessage("Meine werden jeden Tag niedlicher!")
    return
  end
  
  pbMessage("Hallo! Ich bin Maria!")
  pbMessage("Ich liebe niedliche Pokémon über alles!")
  
  if pbConfirmMessage("Möchtest du meine süßen Pokémon sehen?")
    pbTrainerBattle(:LASS, "Maria", "Sind meine Pokémon nicht süß?")
  end
  
  if Phone.can_add?(:LASS, "Maria")
    pbMessage("Du bist so nett!")
    pbMessage("Ich würde gerne deine Freundin sein!")
    
    if pbConfirmMessage("Möchtest du meine Telefonnummer?")
      Phone.add(get_self, :LASS, "Maria")
      pbMessage("Yay! Jetzt können wir über unsere Pokémon sprechen!")
      pbMessage("Ich rufe dich an, wenn ich etwas Süßes erlebt habe!")
    else
      pbMessage("Oh... Na gut, vielleicht ein anderes Mal.")
    end
  end
end

# Beispiel: Wanderer Bruno Event
def hiker_bruno_event
  if !$player.has_pokegear
    pbMessage("Hallo! Ich bin Bruno!")
    pbMessage("Ich wandere durch die Berge mit meinen Pokémon!")
    pbMessage("Schade, dass du kein Pokégear hast...")
    return
  end
  
  if Phone.get(true, :HIKER, "Bruno")
    pbMessage("Hey! Warst du auch in den Bergen unterwegs?")
    pbMessage("Die Natur ist einfach fantastisch!")
    return
  end
  
  pbMessage("Hallo! Ich bin Bruno!")
  pbMessage("Ich liebe es, durch die Berge zu wandern!")
  
  if pbConfirmMessage("Willst du deine Stärke gegen meine testen?")
    pbTrainerBattle(:HIKER, "Bruno", "Meine Pokémon sind hart wie Fels!")
  end
  
  if Phone.can_add?(:HIKER, "Bruno")
    pbMessage("Du bist ein starker Trainer!")
    pbMessage("Wie wäre es, wenn wir in Kontakt bleiben?")
    
    if pbConfirmMessage("Willst du meine Nummer?")
      Phone.add(get_self, :HIKER, "Bruno")
      pbMessage("Prima! Ich rufe dich an, wenn ich etwas Interessantes entdecke!")
      pbMessage("In den Bergen gibt es immer etwas Neues zu erleben!")
    else
      pbMessage("Verstehe... Falls du es dir anders überlegst, findest du mich hier.")
    end
  end
end

# Beispiel: Schönheit Lisa Event
def beauty_lisa_event
  if !$player.has_pokegear
    pbMessage("Hallo Schätzchen! Ich bin Lisa!")
    pbMessage("Meine Pokémon sind die schönsten der Welt!")
    pbMessage("Schade, dass du kein Pokégear hast...")
    return
  end
  
  if Phone.get(true, :BEAUTY, "Lisa")
    pbMessage("Hallo Liebling! Du siehst heute wieder toll aus!")
    pbMessage("Meine Pokémon und ich haben heute einen wunderschönen Tag!")
    return
  end
  
  pbMessage("Hallo Schätzchen! Ich bin Lisa!")
  pbMessage("Ich sammle nur die schönsten Pokémon!")
  
  if pbConfirmMessage("Möchtest du die Schönheit meiner Pokémon bewundern?")
    pbTrainerBattle(:BEAUTY, "Lisa", "Bereite dich auf wahre Schönheit vor!")
  end
  
  if Phone.can_add?(:BEAUTY, "Lisa")
    pbMessage("Du hast einen guten Geschmack!")
    pbMessage("Wir sollten in Kontakt bleiben!")
    
    if pbConfirmMessage("Möchtest du meine Nummer, Schätzchen?")
      Phone.add(get_self, :BEAUTY, "Lisa")
      pbMessage("Wunderbar! Ich rufe dich an, wenn ich etwas Schönes entdecke!")
      pbMessage("Vielleicht können wir auch über Beauty-Tipps sprechen!")
    else
      pbMessage("Oh... Na gut, Liebling. Vielleicht ein anderes Mal.")
    end
  end
end

# Utility-Funktion für Events
def add_phone_number_choice(trainer_type, trainer_name, message = nil)
  message = "Möchtest du meine Telefonnummer?" if !message
  
  return false if !$player.has_pokegear
  return false if !Phone.can_add?(trainer_type, trainer_name)
  
  if pbConfirmMessage(message)
    Phone.add(get_self, trainer_type, trainer_name)
    return true
  end
  
  return false
end

# Beispiel: Joey Event (der berühmte Rattfraz-Trainer)
def joey_event
  if !$player.has_pokegear
    pbMessage("Hey! Ich bin Joey!")
    pbMessage("Mein Rattfraz ist das beste der Welt!")
    pbMessage("Schade, dass du kein Pokégear hast...")
    pbMessage("Sonst könnte ich dir von meinem Rattfraz erzählen!")
    return
  end
  
  if Phone.get(true, :YOUNGSTER, "Joey")
    pbMessage("Hey! Schön dich zu sehen!")
    pbMessage("Mein Rattfraz wird jeden Tag stärker!")
    pbMessage("Es ist wirklich in der Top-Prozent aller Rattfraz!")
    return
  end
  
  pbMessage("Hey! Ich bin Joey!")
  pbMessage("Mein Rattfraz ist das stärkste Pokémon der Welt!")
  pbMessage("Es ist wirklich in der Top-Prozent aller Rattfraz!")
  
  if pbConfirmMessage("Willst du gegen mein super starkes Rattfraz kämpfen?")
    pbTrainerBattle(:YOUNGSTER, "Joey", "Mein Rattfraz wird dir zeigen, was es kann!")
  end
  
  if Phone.can_add?(:YOUNGSTER, "Joey")
    pbMessage("Du bist echt cool!")
    pbMessage("Ich muss dir unbedingt mehr über mein Rattfraz erzählen!")
    
    if pbConfirmMessage("Willst du meine Nummer? Ich rufe dich an!")
      Phone.add(get_self, :YOUNGSTER, "Joey")
      pbMessage("Awesome! Jetzt kann ich dir von meinem Rattfraz erzählen!")
      pbMessage("Mein Rattfraz freut sich schon darauf, mit dir zu sprechen!")
      pbMessage("Ich rufe dich an, wann immer mein Rattfraz etwas Cooles macht!")
    else
      pbMessage("Ach komm schon! Mein Rattfraz ist wirklich das Beste!")
      pbMessage("Na gut, vielleicht überlegst du es dir ja noch mal...")
    end
  end
end

puts "Gen 2 Phone System Beispiel-Events geladen!" 