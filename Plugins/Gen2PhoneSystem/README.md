# Gen 2 Phone System Enhancements

Dieses Plugin erweitert das bestehende Telefonsystem von Pokémon Essentials um Gen 2-ähnliche Features, die das Spiel lebendiger und interaktiver machen.

## Features

### 🔄 Häufigere Anrufe
- NPCs rufen dich häufiger an als im Standard-System
- Anrufe alle 15 Minuten statt 20-40 Minuten
- Konfigurierbare Anrufhäufigkeit

### 💡 Tipp-Anrufe
- NPCs geben dir nützliche Tipps über Pokémon, Training und Gameplay
- 30% Chance für Tipp-Anrufe
- Über 10 verschiedene Tipps verfügbar

### 📚 Geschichten-Anrufe
- NPCs erzählen dir interessante Geschichten und Legenden
- 20% Chance für Geschichten-Anrufe
- Über 10 verschiedene Geschichten verfügbar

### 🌤️ Wetter-Anrufe
- NPCs kommentieren das aktuelle Wetter
- Verschiedene Kommentare für verschiedene Wetterbedingungen
- 15% Chance für Wetter-Anrufe

### 🎭 Erweiterte Trainer-Persönlichkeiten
- Neue Trainer-Typen mit einzigartigen Telefonnachrichten:
  - **Joey**: Der berühmte Rattfraz-Fanatic (automatisch registriert!)
  - **Angler Klaus**: Spricht über Angeln und Wasser-Pokémon
  - **Youngster Tim**: Enthusiastischer junger Trainer
  - **Lass Maria**: Liebevolle Trainerin mit süßen Pokémon
  - **Wanderer Bruno**: Robuster Trainer aus den Bergen
  - **Schönheit Lisa**: Elegante Trainerin mit schönen Pokémon

## Installation

1. Kopiere den `Gen2PhoneSystem` Ordner in deinen `Plugins` Ordner
2. Starte das Spiel neu oder kompiliere die Plugins
3. Das System ist automatisch aktiv
4. **Joey's Nummer wird automatisch registriert**, sobald du ein Pokégear hast!

## Konfiguration

Du kannst die Anrufhäufigkeit und -wahrscheinlichkeiten in der `Gen2PhoneEnhancements.rb` Datei anpassen:

```ruby
module Gen2Phone
  CALL_FREQUENCY_MULTIPLIER = 2.0  # Häufigere Anrufe als Standard
  TIP_CALL_CHANCE = 30             # 30% Chance für Tipp-Anrufe
  STORY_CALL_CHANCE = 20           # 20% Chance für Geschichten-Anrufe
end
```

## Verwendung

### Telefonnummern hinzufügen
Das System funktioniert mit dem bestehenden Telefonsystem. Verwende in Events:

```ruby
# Prüfen ob Nummer hinzugefügt werden kann
if Phone.can_add?(:FISHERMAN, "Klaus")
  # Nummer hinzufügen
  Phone.add(get_self, :FISHERMAN, "Klaus")
end
```

### Debug-Funktionen
Im Debug-Menü unter "Player" findest du "Gen 2 Phone Test" mit folgenden Optionen:
- Tipp-Anruf testen
- Geschichten-Anruf testen
- Wetter-Anruf testen
- **Joey Rattfraz-Anruf testen**
- Zufälligen Anruf forcieren
- Anruf-Timer zurücksetzen

## Neue Telefonnachrichten

Das Plugin beinhaltet vollständig deutsche Telefonnachrichten für verschiedene Trainer-Typen. Alle Nachrichten sind in der `phone.txt` Datei im PBS-Ordner definiert.

### Beispiel-Nachrichten:
- **Joey**: "Mein Rattfraz ist wirklich in der Top-Prozent aller Rattfraz!"
- **Angler**: "Ich war heute wieder angeln. Mein Pokémon hilft mir dabei!"
- **Youngster**: "Mein Pokémon wird immer stärker! Es hört richtig gut auf mich."
- **Lass**: "Mein Pokémon ist so süß! Ich liebe es über alles."

## Kompatibilität

- Kompatibel mit Pokémon Essentials v21.1
- Funktioniert mit allen bestehenden Telefon-Features
- Erweitert das System ohne bestehende Funktionalität zu brechen

## Anpassungen

### Neue Tipps hinzufügen
Bearbeite das `TIPS` Array in der `Gen2PhoneEnhancements.rb`:

```ruby
TIPS = [
  "Dein neuer Tipp hier!",
  # ... weitere Tipps
]
```

### Neue Geschichten hinzufügen
Bearbeite das `STORIES` Array:

```ruby
STORIES = [
  "Deine neue Geschichte hier!",
  # ... weitere Geschichten
]
```

### Neue Trainer-Typen hinzufügen
Füge neue Abschnitte in der `PBS/phone.txt` Datei hinzu:

```
[TRAINER_TYPE,Name]
Intro = Hallo! Hier ist Name.
Body1 = Nachricht über Pokémon...
Body2 = Nachricht über Erlebnisse...
BattleRequest = Kampf-Anfrage...
End = Verabschiedung...
```

## Technische Details

Das Plugin nutzt Ruby's `alias` Mechanismus, um bestehende Methoden zu erweitern, ohne sie zu ersetzen. Dies gewährleistet maximale Kompatibilität mit anderen Plugins.

## Lizenz

Dieses Plugin ist Teil deines Pokémon Essentials Projekts und unterliegt den gleichen Lizenzbedingungen. 