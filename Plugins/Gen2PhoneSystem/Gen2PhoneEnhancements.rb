#===============================================================================
# Gen 2 Phone System Enhancements
# Erweitert das bestehende Telefonsystem um Gen 2-ähnliche Features
#===============================================================================

module Gen2Phone
  # Konfiguration für Gen 2-ähnliche Features
  CALL_FREQUENCY_MULTIPLIER = 2.0  # Häufigere Anrufe als Standard
  TIP_CALL_CHANCE = 30             # 30% Chance für Tipp-Anrufe
  STORY_CALL_CHANCE = 20           # 20% Chance für Geschichten-Anrufe
  
  # Tipps, die NPCs geben können
  TIPS = [
    "Wusstest du, dass Pokémon bei Regen andere Attacken lernen können?",
    "Ich habe gehört, dass manche Pokémon nur zu bestimmten Tageszeiten entwickeln!",
    "Tipp: Beeren können deine Pokémon im Kampf heilen!",
    "Hast du schon mal probiert, mit verschiedenen Pokéballs zu experimentieren?",
    "Manche Pokémon sind nur bei bestimmtem Wetter zu finden!",
    "Vergiss nicht, deine Pokémon regelmäßig zu heilen!",
    "Ich habe gehört, dass Freundschaft bei der Entwicklung wichtig ist!",
    "Tipp: Schau dir die Fähigkeiten deiner Pokémon genau an!",
    "Manche Attacken sind bei bestimmten Wetterbedingungen stärker!",
    "Hast du schon mal versucht, Pokémon zu züchten?"
  ]
  
  # Geschichten, die NPCs erzählen können
  STORIES = [
    "Neulich habe ich einen Trainer getroffen, der nur mit Käfer-Pokémon kämpft!",
    "Ich habe gehört, dass es in alten Ruinen seltene Pokémon gibt...",
    "Mein Opa hat mir erzählt, dass früher Pokémon und Menschen zusammen gelebt haben.",
    "Kennst du die Legende über das Pokémon, das Wünsche erfüllt?",
    "Ich habe mal einen Trainer gesehen, der mit seinem Pokémon sprechen konnte!",
    "Es gibt Gerüchte über ein geheimes Labor in den Bergen...",
    "Manche sagen, dass Pokémon die Gefühle ihrer Trainer spüren können.",
    "Ich habe gehört, dass es Pokémon gibt, die aus anderen Welten kommen!",
    "Kennst du die Geschichte über den Trainer, der nie verloren hat?",
    "Es heißt, dass manche Pokémon Träume haben, genau wie wir!"
  ]
  
  # Spezielle Joey Rattfraz Geschichten
  JOEY_RATTFRAZ_STORIES = [
    "Mein Rattfraz hat heute einen ganzen Apfel in einem Bissen gegessen!",
    "Weißt du, mein Rattfraz ist wirklich in der Top-Prozent aller Rattfraz!",
    "Mein Rattfraz hat heute drei andere Rattfraz in Folge besiegt!",
    "Ich habe mein Rattfraz heute beim Schwanzwedeln beobachtet - so süß!",
    "Mein Rattfraz kann schneller rennen als jedes andere Pokémon!",
    "Heute hat mein Rattfraz einen riesigen Käfer gefangen!",
    "Mein Rattfraz hat mich heute vor einem wilden Pokémon beschützt!",
    "Weißt du, mein Rattfraz versteht jedes Wort, das ich sage!",
    "Mein Rattfraz hat heute ein Nickerchen in der Sonne gemacht!",
    "Ich glaube, mein Rattfraz ist das klügste Pokémon der Welt!"
  ]
  
  # Wetterbasierte Kommentare
  WEATHER_COMMENTS = {
    :sun => [
      "Das Wetter ist heute perfekt für ein Abenteuer!",
      "Bei diesem Sonnenschein sind die Pokémon besonders aktiv!",
      "Perfektes Wetter zum Trainieren!"
    ],
    :rain => [
      "Der Regen bringt bestimmt seltene Pokémon hervor!",
      "Bei Regen sind Wasser-Pokémon besonders stark!",
      "Ich liebe das Geräusch von Regen!"
    ],
    :snow => [
      "Im Schnee sieht alles so friedlich aus!",
      "Eis-Pokémon lieben dieses Wetter!",
      "Pass auf, dass du nicht ausrutschst!"
    ],
    :sandstorm => [
      "Dieser Sandsturm ist wirklich heftig!",
      "Boden-Pokémon fühlen sich bei diesem Wetter wohl!",
      "Bleib in Sicherheit bei diesem Wetter!"
    ]
  }
  
  module_function
  
  def get_random_tip
    return TIPS.sample
  end
  
  def get_random_story
    return STORIES.sample
  end
  
  def get_joey_rattfraz_story
    return JOEY_RATTFRAZ_STORIES.sample
  end
  
  def get_weather_comment
    # Vereinfacht - in einem echten Spiel würde man das aktuelle Wetter prüfen
    weather_types = WEATHER_COMMENTS.keys
    weather = weather_types.sample
    return WEATHER_COMMENTS[weather].sample
  end
  
  def should_make_tip_call?
    return rand(100) < TIP_CALL_CHANCE
  end
  
  def should_make_story_call?
    return rand(100) < STORY_CALL_CHANCE
  end
end

#===============================================================================
# Erweiterte Phone Call Klasse
#===============================================================================
class Phone
  module Call
    class << self
      alias gen2_make_incoming make_incoming
      
      def make_incoming
        return if !can_make?
        contact = get_random_trainer_for_incoming_call
        return if !contact
        
        # Bestimme Anruftyp
        call_type = determine_call_type(contact)
        
        case call_type
        when :tip
          make_tip_call(contact)
        when :story
          make_story_call(contact)
        when :weather
          make_weather_call(contact)
        when :joey_rattfraz
          make_joey_rattfraz_call(contact)
        else
          gen2_make_incoming # Normaler Anruf
        end
      end
      
      private
      
      def determine_call_type(contact)
        # Spezielle Joey Behandlung - er redet IMMER über sein Rattfraz
        if contact.trainer_type == :YOUNGSTER && contact.name == "Joey"
          return :joey_rattfraz
        elsif Gen2Phone.should_make_tip_call?
          return :tip
        elsif Gen2Phone.should_make_story_call?
          return :story
        elsif rand(100) < 15 # 15% Chance für Wetter-Kommentare
          return :weather
        else
          return :normal
        end
      end
      
      def make_tip_call(contact)
        start_message(contact)
        
        # Begrüßung
        greeting = get_random_greeting(contact)
        pbMessage(greeting)
        
        # Tipp
        tip = Gen2Phone.get_random_tip
        pbMessage("Übrigens, #{tip}")
        
        # Verabschiedung
        farewell = get_random_farewell(contact)
        pbMessage(farewell)
        
        end_message(contact)
      end
      
      def make_story_call(contact)
        start_message(contact)
        
        # Begrüßung
        greeting = get_random_greeting(contact)
        pbMessage(greeting)
        
        # Geschichte
        story = Gen2Phone.get_random_story
        pbMessage("Ich muss dir etwas erzählen! #{story}")
        
        # Verabschiedung
        farewell = get_random_farewell(contact)
        pbMessage(farewell)
        
        end_message(contact)
      end
      
      def make_weather_call(contact)
        start_message(contact)
        
        # Begrüßung
        greeting = get_random_greeting(contact)
        pbMessage(greeting)
        
        # Wetter-Kommentar
        weather_comment = Gen2Phone.get_weather_comment
        pbMessage(weather_comment)
        
        # Verabschiedung
        farewell = get_random_farewell(contact)
        pbMessage(farewell)
        
        end_message(contact)
      end
      
      def make_joey_rattfraz_call(contact)
        start_message(contact)
        
        # Joey's typische Begrüßung
        greetings = [
          "Hey #{$player.name}! Joey hier!",
          "#{$player.name}! Du wirst nicht glauben, was mein Rattfraz heute gemacht hat!",
          "Hi #{$player.name}! Joey hier. Mein Rattfraz ist einfach unglaublich!",
          "#{$player.name}! Rate mal, was mein Rattfraz gerade getan hat!"
        ]
        pbMessage(greetings.sample)
        
        # Rattfraz Geschichte
        story = Gen2Phone.get_joey_rattfraz_story
        pbMessage(story)
        
        # Zusätzlicher Rattfraz Kommentar
        extra_comments = [
          "Ist das nicht der Wahnsinn?",
          "Mein Rattfraz ist wirklich das Beste!",
          "Ich bin so stolz auf mein Rattfraz!",
          "Kein anderes Rattfraz ist so toll wie meins!",
          "Mein Rattfraz ist einfach perfekt!"
        ]
        pbMessage(extra_comments.sample)
        
        # Joey's typische Verabschiedung
        farewells = [
          "Bis bald! Grüß dein Team von meinem Rattfraz!",
          "Ciao! Mein Rattfraz und ich müssen weiter trainieren!",
          "Bis später! Mein Rattfraz freut sich schon auf unser nächstes Gespräch!",
          "Tschüss! Mein Rattfraz sagt auch Hallo!"
        ]
        pbMessage(farewells.sample)
        
        end_message(contact)
      end
      
      def get_random_greeting(contact)
        greetings = [
          "Hallo #{$player.name}! Hier ist #{contact.name}.",
          "Hi #{$player.name}! #{contact.name} hier.",
          "#{$player.name}! Hier ist #{contact.name}. Wie geht's?",
          "Hallo! #{contact.name} hier. Hast du eine Minute?"
        ]
        return greetings.sample
      end
      
      def get_random_farewell(contact)
        farewells = [
          "Bis bald!",
          "Ciao! Wir sehen uns!",
          "Tschüss! Pass auf dich auf!",
          "Bis dann! Grüß deine Pokémon von mir!",
          "Ciao! Bleib stark!",
          "Bis später! Viel Glück!"
        ]
        return farewells.sample
      end
    end
  end
end

#===============================================================================
# Häufigere Anrufe (Gen 2 Style)
#===============================================================================
EventHandlers.add(:on_frame_update, :gen2_phone_call_counter,
  proc {
    next if !$player&.has_pokegear
    # Don't count down various phone times if other things are happening
    next if $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
    next if $game_player.move_route_forcing || pbMapInterpreterRunning?
    
    # Count down time to next phone call (häufiger als normal)
    if $PokemonGlobal.phone.time_to_next_call <= 0
      # Gen 2 hatte häufigere Anrufe - jetzt alle 15 Minuten
      call_interval = 15 * 60.0  # 15 Minuten in Sekunden
      $PokemonGlobal.phone.time_to_next_call = call_interval
    end
  }
)

#===============================================================================
# Debug-Befehle für das Gen 2 Phone System
#===============================================================================
MenuHandlers.add(:debug_menu, :gen2_phone_test, {
  "name"        => _INTL("Gen 2 Phone Test"),
  "parent"      => :player_menu,
  "description" => _INTL("Teste Gen 2 Phone System Features"),
  "effect"      => proc {
    cmd = 0
    loop do
      cmds = [
        _INTL("Tipp-Anruf testen"),
        _INTL("Geschichten-Anruf testen"),
        _INTL("Wetter-Anruf testen"),
        _INTL("Joey Rattfraz-Anruf testen"),
        _INTL("Zufälligen Anruf forcieren"),
        _INTL("Anruf-Timer zurücksetzen")
      ]
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      break if cmd < 0
      
      case cmd
      when 0 # Tipp-Anruf
        if $PokemonGlobal.phone.contacts.any? { |c| c.visible? }
          contact = $PokemonGlobal.phone.contacts.select { |c| c.visible? }.sample
          Phone::Call.send(:make_tip_call, contact)
        else
          pbMessage(_INTL("Keine Kontakte verfügbar."))
        end
      when 1 # Geschichten-Anruf
        if $PokemonGlobal.phone.contacts.any? { |c| c.visible? }
          contact = $PokemonGlobal.phone.contacts.select { |c| c.visible? }.sample
          Phone::Call.send(:make_story_call, contact)
        else
          pbMessage(_INTL("Keine Kontakte verfügbar."))
        end
      when 2 # Wetter-Anruf
        if $PokemonGlobal.phone.contacts.any? { |c| c.visible? }
          contact = $PokemonGlobal.phone.contacts.select { |c| c.visible? }.sample
          Phone::Call.send(:make_weather_call, contact)
        else
          pbMessage(_INTL("Keine Kontakte verfügbar."))
        end
      when 3 # Joey Rattfraz-Anruf
        # Erstelle einen temporären Joey Kontakt für den Test
        joey_contact = Phone::Contact.new(true, 1, 1, :YOUNGSTER, "Joey", 1, 0, 0)
        Phone::Call.send(:make_joey_rattfraz_call, joey_contact)
      when 4 # Zufälligen Anruf forcieren
        Phone::Call.make_incoming
      when 5 # Timer zurücksetzen
        $PokemonGlobal.phone.time_to_next_call = 0
        pbMessage(_INTL("Anruf-Timer zurückgesetzt."))
      end
    end
  }
})

#===============================================================================
# Erweiterte Kontakt-Hinzufügung mit mehr Optionen
#===============================================================================
class Phone
  class << self
    alias gen2_add add
    
    def add(*args)
      result = gen2_add(*args)
      
      if result
        # Zusätzliche Nachricht für Gen 2 Style
        pbMessage(_INTL("Jetzt kannst du angerufen werden!"))
        pbMessage(_INTL("Vielleicht rufe ich dich mal an, wenn ich etwas Interessantes erlebt habe!"))
      end
      
      return result
    end
  end
end

#===============================================================================
# Joey's Nummer automatisch registrieren (Gen 2 Style)
#===============================================================================
EventHandlers.add(:on_new_game, :register_joey_phone,
  proc {
    # Joey's Nummer automatisch hinzufügen wenn das Spiel startet
    if $player&.has_pokegear
      Phone.add_silent(1, 1, :YOUNGSTER, "Joey", 1, 0, 0) # Map 1, Event 1 als Platzhalter
      puts "Joey's Nummer automatisch registriert!"
    end
  }
)

# Für bestehende Spielstände - Joey hinzufügen falls noch nicht vorhanden
EventHandlers.add(:on_frame_update, :check_joey_registration,
  proc {
    # Prüfe einmal pro Sekunde, ob Joey registriert werden muss
    next if !$player&.has_pokegear
    next if Phone.get(true, :YOUNGSTER, "Joey") # Joey bereits registriert
    next if Graphics.frame_count % 60 != 0 # Nur einmal pro Sekunde prüfen
    
    # Joey automatisch hinzufügen
    Phone.add_silent(1, 1, :YOUNGSTER, "Joey", 1, 0, 0)
    pbMessage(_INTL("Joey's Nummer wurde automatisch zu deinem Pokégear hinzugefügt!"))
    pbMessage(_INTL("Er wird dich bald anrufen und von seinem Rattfraz erzählen!"))
  }
)

puts "Gen 2 Phone System Enhancements geladen!" 