#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Intelligenter Internationaler Pokemon Event Text Übersetzer
Übersetzt automatisch jede zweite Zeile ins Deutsche
"""

import re
import sys
import os
from typing import List, Dict, Tuple

class PokemonTranslator:
    def __init__(self):
        # Pokémon-spezifische Namen
        self.pokemon_names = {
            "Oak": "Eich",
            "Professor Oak": "Professor Eich",
            "Pokémon": "Pokémon",
            "Pokédex": "Pokédex"
        }
        
        # Basis-Übersetzungen für häufige Begriffe
        self.translations = {
            # Grüße und höfliche Phrasen
            "Hello": "Hallo",
            "Hi": "Hi",
            "Welcome": "Willkommen", 
            "Thank you": "Danke",
            "Thanks": "Danke",
            "Sorry": "Entschuldigung",
            "Excuse me": "Entschuldige",
            "Please": "Bitte",
            
            # Ja/Nein/Grundoptionen
            "Yes": "Ja",
            "No": "Nein", 
            "OK": "OK",
            "Okay": "Okay",
            "Quit": "Beenden",
            "Exit": "Verlassen",
            "Cancel": "Abbrechen",
            "Continue": "Weiter",
            "Choose": "Wähle",
            "Select": "Auswählen",
            "Evaluate": "Bewerten",
            
            # Pokemon-spezifisch
            "Adventure": "Abenteuer",
            "Controls": "Steuerung", 
            "Boy": "Junge",
            "Girl": "Mädchen",
            "Trainer": "Trainer",
            "battle": "Kampf",
            "catch": "fangen",
            "caught": "gefangen",
            
            # Häufige Verben
            "go": "gehen",
            "come": "kommen", 
            "see": "sehen",
            "look": "schauen",
            "help": "helfen",
            "give": "geben",
            "take": "nehmen",
            "get": "bekommen",
            "have": "haben",
            "make": "machen",
            "do": "tun",
            "say": "sagen",
            "tell": "erzählen",
            "know": "wissen",
            "think": "denken",
            "want": "wollen",
            "need": "brauchen",
            "use": "verwenden",
            "find": "finden",
            "show": "zeigen",
            "call": "rufen",
            "talk": "sprechen",
            "speak": "sprechen",
            "follow": "folgen",
            "keep": "behalten",
            "stop": "aufhören",
            "wait": "warten",
            "ready": "bereit",
            "study": "studieren",
            "learn": "lernen",
            "play": "spielen",
            "work": "arbeiten",
            "live": "leben",
            "walk": "gehen",
            "run": "laufen",
            "jump": "springen",
            "face": "begegnen",
            "meet": "treffen",
            "enter": "betreten",
            "leave": "verlassen",
            "return": "zurückkehren",
            "travel": "reisen",
            "journey": "Reise",
            "adventure": "Abenteuer",
            "world": "Welt",
            "story": "Geschichte",
            "mystery": "Geheimnis",
            "mysteries": "Geheimnisse",
            "solve": "lösen",
            "overcome": "überwinden",
            "challenge": "Herausforderung",
            "challenges": "Herausforderungen",
            "power": "Kraft",
            "powerful": "mächtig",
            "strong": "stark",
            "weak": "schwach",
            "difficult": "schwierig",
            "easy": "einfach",
            "hard": "schwer",
            "fun": "Spaß",
            "tough": "schwer",
            "important": "wichtig",
            "special": "besonders",
            "great": "großartig",
            "good": "gut",
            "bad": "schlecht",
            "better": "besser",
            "best": "beste",
            "new": "neu",
            "old": "alt",
            "young": "jung",
            "long": "lang",
            "short": "kurz",
            "big": "groß",
            "small": "klein",
            "many": "viele",
            "much": "viel",
            "more": "mehr",
            "most": "meiste",
            "all": "alle",
            "every": "jeder",
            "some": "einige",
            "few": "wenige",
            "other": "andere",
            "another": "ein anderer",
            "same": "gleich",
            "different": "anders",
            "first": "erste",
            "second": "zweite",
            "last": "letzte",
            "next": "nächste",
            "right": "richtig",
            "wrong": "falsch",
            "true": "wahr",
            "false": "falsch",
            
            # Orte und Richtungen
            "here": "hier",
            "there": "dort",
            "where": "wo",
            "everywhere": "überall",
            "anywhere": "irgendwo",
            "somewhere": "irgendwo",
            "nowhere": "nirgendwo",
            "home": "Zuhause",
            "house": "Haus",
            "place": "Ort",
            "town": "Stadt",
            "city": "Stadt",
            "road": "Straße",
            "way": "Weg",
            "path": "Pfad",
            "door": "Tür",
            "doors": "Türen",
            "outside": "draußen",
            "inside": "drinnen",
            "over": "über", 
            "under": "unter",
            "around": "um",
            "through": "durch",
            "across": "über",
            "along": "entlang",
            "up": "oben",
            "down": "unten",
            "left": "links",
            "right": "rechts",
            "front": "vorne",
            "back": "hinten",
            "side": "Seite",
            "top": "oben",
            "bottom": "unten",
            "center": "Mitte",
            "middle": "Mitte",
            "corner": "Ecke",
            "edge": "Rand",
            "end": "Ende",
            "beginning": "Anfang",
            "start": "Start",
            
            # Zeit
            "time": "Zeit",
            "day": "Tag",
            "night": "Nacht", 
            "morning": "Morgen",
            "afternoon": "Nachmittag",
            "evening": "Abend",
            "today": "heute",
            "tomorrow": "morgen",
            "yesterday": "gestern",
            "now": "jetzt",
            "then": "dann",
            "later": "später",
            "before": "vorher",
            "after": "nachher",
            "always": "immer",
            "never": "niemals",
            "sometimes": "manchmal",
            "often": "oft",
            "usually": "normalerweise",
            "again": "wieder",
            "still": "noch",
            "already": "schon",
            "yet": "noch",
            "soon": "bald",
            "early": "früh",
            "late": "spät",
            "fast": "schnell",
            "slow": "langsam",
            "quick": "schnell",
            
            # Personen
            "people": "Leute",
            "person": "Person",
            "man": "Mann",
            "woman": "Frau",
            "child": "Kind",
            "children": "Kinder",
            "baby": "Baby",
            "boy": "Junge",
            "girl": "Mädchen",
            "friend": "Freund",
            "friends": "Freunde",
            "family": "Familie",
            "mother": "Mutter",
            "father": "Vater",
            "son": "Sohn",
            "daughter": "Tochter",
            "brother": "Bruder",
            "sister": "Schwester",
            "teacher": "Lehrer",
            "student": "Schüler",
            "professor": "Professor",
            
            # Dinge
            "thing": "Sache",
            "things": "Sachen",
            "something": "etwas",
            "anything": "etwas",
            "nothing": "nichts",
            "everything": "alles",
            "item": "Gegenstand",
            "object": "Objekt",
            "stuff": "Zeug",
            "food": "Essen",
            "water": "Wasser",
            "money": "Geld",
            "game": "Spiel",
            "picture": "Bild",
            "sound": "Geräusch",
            "music": "Musik",
            "voice": "Stimme",
            "word": "Wort",
            "words": "Wörter",
            "name": "Name",
            "number": "Nummer",
            "information": "Information",
            "idea": "Idee",
            "problem": "Problem",
            "question": "Frage",
            "answer": "Antwort",
            "reason": "Grund",
            "way": "Weg",
            "example": "Beispiel",
            "examples": "Beispiele",
            "part": "Teil",
            "piece": "Stück",
            "group": "Gruppe",
            "team": "Team",
            "level": "Level",
            "type": "Typ",
            "kind": "Art",
            "sort": "Art",
            "class": "Klasse",
            "system": "System",
            "program": "Programm",
            "file": "Datei",
            "folder": "Ordner",
            "page": "Seite",
            "screen": "Bildschirm",
            "window": "Fenster",
            "menu": "Menü",
            "option": "Option",
            "choice": "Auswahl",
            "decision": "Entscheidung",
            
            # Farben
            "color": "Farbe",
            "red": "rot",
            "blue": "blau", 
            "green": "grün",
            "yellow": "gelb",
            "black": "schwarz",
            "white": "weiß",
            "gray": "grau",
            "grey": "grau",
            "brown": "braun",
            "orange": "orange",
            "pink": "rosa",
            "purple": "lila",
            
            # Zahlen
            "one": "eins",
            "two": "zwei", 
            "three": "drei",
            "four": "vier",
            "five": "fünf",
            "six": "sechs",
            "seven": "sieben",
            "eight": "acht",
            "nine": "neun",
            "ten": "zehn",
            "hundred": "hundert",
            "thousand": "tausend",
            
            # Verbindungswörter
            "and": "und",
            "or": "oder",
            "but": "aber", 
            "so": "also",
            "because": "weil",
            "if": "wenn",
            "when": "wenn",
            "while": "während",
            "until": "bis",
            "since": "seit",
            "for": "für",
            "with": "mit",
            "without": "ohne",
            "about": "über",
            "from": "von",
            "to": "zu",
            "in": "in",
            "on": "auf",
            "at": "bei",
            "by": "von",
            "near": "nah",
            "far": "weit",
            "between": "zwischen",
            "among": "unter",
            "during": "während",
            "before": "vor",
            "after": "nach",
            "above": "über",
            "below": "unter",
            "beside": "neben",
            "behind": "hinter",
            "ahead": "voraus",
            
            # Modalwörter
            "can": "können",
            "could": "könnte",
            "will": "werden", 
            "would": "würde",
            "should": "sollte",
            "must": "müssen",
            "may": "dürfen",
            "might": "könnte",
            "shall": "sollen",
            
            # Häufige Adjektive
            "happy": "glücklich",
            "sad": "traurig",
            "angry": "wütend",
            "excited": "aufgeregt",
            "surprised": "überrascht",
            "worried": "besorgt",
            "scared": "erschrocken",
            "tired": "müde",
            "hungry": "hungrig",
            "cold": "kalt",
            "hot": "heiß",
            "warm": "warm",
            "cool": "kühl",
            "nice": "nett",
            "kind": "freundlich",
            "mean": "gemein",
            "funny": "lustig",
            "serious": "ernst",
            "smart": "klug",
            "stupid": "dumm",
            "crazy": "verrückt",
            "normal": "normal",
            "strange": "seltsam",
            "weird": "komisch",
            "interesting": "interessant",
            "boring": "langweilig",
            "exciting": "aufregend",
            "amazing": "erstaunlich",
            "wonderful": "wunderbar",
            "terrible": "schrecklich",
            "awful": "furchtbar",
            "beautiful": "schön",
            "pretty": "hübsch",
            "ugly": "hässlich",
            "clean": "sauber",
            "dirty": "schmutzig",
            "quiet": "leise",
            "loud": "laut",
            "empty": "leer",
            "full": "voll",
            "open": "offen",
            "closed": "geschlossen",
            "heavy": "schwer",
            "light": "leicht",
            "dark": "dunkel",
            "bright": "hell",
            "clear": "klar",
            "safe": "sicher",
            "dangerous": "gefährlich",
            "careful": "vorsichtig",
            "sure": "sicher",
            "certain": "sicher",
            "possible": "möglich",
            "impossible": "unmöglich",
            "easy": "einfach",
            "simple": "einfach",
            "hard": "schwer",
            "difficult": "schwierig",
            "free": "frei",
            "busy": "beschäftigt",
            "available": "verfügbar",
            "ready": "bereit",
            "perfect": "perfekt",
            "correct": "richtig",
            "wrong": "falsch",
            "broken": "kaputt",
            "fixed": "repariert",
            "lost": "verloren",
            "found": "gefunden",
            "missing": "fehlend",
            "complete": "vollständig",
            "finished": "fertig",
            "done": "gemacht"
        }
        
        # Du-Form Regeln
        self.du_form_rules = {
            r'\byou\b': 'du',
            r'\bYou\b': 'Du',
            r'\byour\b': 'dein',
            r'\bYour\b': 'Dein',
            r'\byou\'re\b': 'du bist',
            r'\bYou\'re\b': 'Du bist',
            r'\byou are\b': 'du bist',
            r'\bYou are\b': 'Du bist',
            r'\byou have\b': 'du hast',
            r'\bYou have\b': 'Du hast',
            r'\byou can\b': 'du kannst',
            r'\bYou can\b': 'Du kannst',
            r'\byou will\b': 'du wirst',
            r'\bYou will\b': 'Du wirst',
            r'\byou should\b': 'du solltest',
            r'\bYou should\b': 'Du solltest',
            r'\byou must\b': 'du musst',
            r'\bYou must\b': 'Du musst',
            r'\byou need\b': 'du brauchst',
            r'\bYou need\b': 'Du brauchst',
            r'\byou want\b': 'du willst',
            r'\bYou want\b': 'Du willst'
        }

    def should_skip_line(self, line: str) -> bool:
        """Prüft ob eine Zeile übersprungen werden soll"""
        line = line.strip()
        if not line:
            return True
        if line.startswith("#"):
            return True  
        if line.startswith("[Map"):
            return True
        if line.startswith("------"):
            return True
        return False

    def translate_line(self, line: str) -> str:
        """Übersetzt eine einzelne Zeile"""
        if self.should_skip_line(line):
            return line
            
        result = line
        
        # 1. Pokémon-Namen ersetzen
        for eng, ger in self.pokemon_names.items():
            pattern = r'\b' + re.escape(eng) + r'\b'
            result = re.sub(pattern, ger, result)
        
        # 2. Wort-für-Wort Übersetzungen (längste zuerst)
        sorted_words = sorted(self.translations.keys(), key=len, reverse=True)
        for eng_word in sorted_words:
            ger_word = self.translations[eng_word]
            pattern = r'\b' + re.escape(eng_word) + r'\b'
            result = re.sub(pattern, ger_word, result, flags=re.IGNORECASE)
        
        # 3. Du-Form anwenden
        for pattern, replacement in self.du_form_rules.items():
            result = re.sub(pattern, replacement, result)
        
        return result

    def process_file(self, filename: str):
        """Verarbeitet die EVENT_TEXTS.txt"""
        print(f"🌍 Intelligenter Pokemon Übersetzer")
        print(f"📁 Verarbeite: {filename}")
        
        if not os.path.exists(filename):
            print(f"❌ Datei nicht gefunden: {filename}")
            return
        
        # Datei lesen
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except:
            with open(filename, 'r', encoding='latin-1') as f:
                lines = f.readlines()
        
        total = len(lines)
        translated_lines = []
        changes = 0
        
        print(f"📊 Gefunden: {total:,} Zeilen")
        
        for i, line in enumerate(lines, 1):
            original_line = line.rstrip('\n\r')
            
            # Jede zweite Zeile übersetzen
            if i % 2 == 0:
                translated = self.translate_line(original_line)
                if translated != original_line:
                    changes += 1
                    if changes <= 5:  # Zeige erste 5 Änderungen
                        print(f"  🔄 Zeile {i}: '{original_line}' → '{translated}'")
                translated_lines.append(translated + '\n')
            else:
                translated_lines.append(line)
            
            # Progress
            if i % 2000 == 0:
                progress = (i / total) * 100
                print(f"  ⏳ {progress:.1f}% ({i:,}/{total:,})")
        
        # Backup erstellen
        backup = filename + '.backup'
        if not os.path.exists(backup):
            print(f"💾 Erstelle Backup: {backup}")
            with open(backup, 'w', encoding='utf-8') as f:
                f.writelines(lines)
        
        # Übersetzte Version speichern
        output_file = filename.replace('.txt', '_intelligent.txt')
        print(f"💾 Speichere: {output_file}")
        with open(output_file, 'w', encoding='utf-8') as f:
            f.writelines(translated_lines)
        
        print(f"✅ Fertig!")
        print(f"📈 {changes:,} Übersetzungen gemacht")
        print(f"📁 Backup: {backup}")
        print(f"📁 Übersetzt: {output_file}")
        
        # Anwenden?
        response = input(f"\n🔄 Übersetzung auf {filename} anwenden? (j/n): ")
        if response.lower() in ['j', 'ja', 'y', 'yes']:
            with open(output_file, 'r', encoding='utf-8') as f:
                content = f.read()
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Angewendet auf {filename}!")
        else:
            print(f"ℹ️ Nicht angewendet. Datei verfügbar: {output_file}")

def main():
    translator = PokemonTranslator()
    
    # Dateiname aus Argumenten oder Standard
    filename = sys.argv[1] if len(sys.argv) > 1 else "EVENT_TEXTS.txt"
    
    translator.process_file(filename)

if __name__ == "__main__":
    main() 