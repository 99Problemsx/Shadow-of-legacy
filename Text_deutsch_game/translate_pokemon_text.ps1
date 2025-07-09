# Pokemon Event Text Translator Script
# Übersetzt jede zweite Zeile der EVENT_TEXTS.txt ins Deutsche

param(
    [string]$InputFile = "EVENT_TEXTS.txt",
    [string]$OutputFile = "EVENT_TEXTS_translated.txt"
)

# Überprüfe ob die Eingabedatei existiert
if (-not (Test-Path $InputFile)) {
    Write-Error "Datei $InputFile wurde nicht gefunden!"
    exit 1
}

Write-Host "Starte Übersetzung von $InputFile..." -ForegroundColor Green

# Lade alle Zeilen
$lines = Get-Content $InputFile -Encoding UTF8

# Übersetzungs-Dictionary für häufige Begriffe
$translations = @{
    "Hello, \\PN!" = "Hallo, \\PN!"
    "Hello!" = "Hallo!"
    "Hello" = "Hallo"
    "Hi" = "Hi"
    "Welcome to the world of Pokémon" = "Willkommen in der Welt der Pokémon"
    "Welcome" = "Willkommen"
    "Thank you" = "Danke"
    "Thanks" = "Danke"
    "Yes" = "Ja"
    "No" = "Nein"
    "Quit" = "Beenden"
    "Exit" = "Verlassen"
    "Cancel" = "Abbrechen"
    "Continue" = "Weiter"
    "Choose" = "Wähle"
    "Select" = "Auswählen"
    "Professor Oak" = "Professor Eich"
    "Oak:" = "Eich:"
    "Oak" = "Eich"
    "My name is Oak" = "Mein Name ist Eich"
    "My name is" = "Mein Name ist"
    "I am" = "Ich bin"
    "People call me the Pokémon Professor" = "Die Leute nennen mich den Pokémon-Professor"
    "Sorry to keep you waiting" = "Entschuldige, dass du warten musstest"
    "If you need help, I am certainly capable of giving it" = "Wenn du Hilfe brauchst, kann ich sie dir gerne geben"
    "Well then, without further ado" = "Nun denn, ohne weitere Umschweife"
    "You are about to enter a world\\nwhere you will embark on a grand\\nadventure of your very own" = "Du stehst kurz davor, eine Welt zu betreten,\\nin der du ein großartiges\\nAbenteuer ganz für dich erleben wirst"
    "Speak to people and check things\\n wherever you go, be it in towns,\\nroads or caves.\\n Gather information and hints from\\n every possible source" = "Sprich mit Leuten und untersuche Dinge,\\n überall wo du hingehst, sei es in Städten,\\nauf Straßen oder in Höhlen.\\n Sammle Informationen und Hinweise aus\\n jeder möglichen Quelle"
    "New paths will open to you when\\n you help people in need, overcome\\n challenges, and solve mysteries" = "Neue Wege werden sich dir öffnen, wenn\\n du Menschen in Not hilfst, Herausforderungen\\n überwindest und Geheimnisse löst"
    "At times, you will be challenged\\n by others to a battle.\\n At other times, wild creatures\\nmay stand in your way.\\n\\n By overcoming such hurdles,\\nyou will gain great power" = "Manchmal wirst du von anderen\\n zu einem Kampf herausgefordert.\\n Ein andermal könnten wilde Kreaturen\\ndir im Weg stehen.\\n\\n Indem du solche Hürden überwindest,\\nwirst du große Kraft erlangen"
    "However, your adventure is not\\n solely about becoming powerful" = "Jedoch geht es bei deinem Abenteuer nicht\\n nur darum, mächtig zu werden"
    "On your travels, we hope that\\n you will meet countless people\\n and, through them, achieve\\npersonal growth.\\n\\n This is the most important\\nobjective of this adventure" = "Auf deinen Reisen hoffen wir, dass\\n du unzählige Menschen triffst\\n und durch sie persönliches\\nWachstum erreichst.\\n\\n Das ist das wichtigste\\nZiel dieses Abenteuers"
    "This world is inhabited by creatures we call Pokémon" = "Diese Welt wird von Kreaturen bewohnt, die wir Pokémon nennen"
    "People and Pokémon live together by supporting each other" = "Menschen und Pokémon leben zusammen, indem sie sich gegenseitig unterstützen"
    "Some people play with Pokémon, some battle with them" = "Manche Menschen spielen mit Pokémon, manche kämpfen mit ihnen"
    "But we don't know everything about Pokémon yet" = "Aber wir wissen noch nicht alles über Pokémon"
    "There are still many mysteries to solve" = "Es gibt noch viele Geheimnisse zu lösen"
    "That's why I study Pokémon every day" = "Deshalb studiere ich Pokémon jeden Tag"
    "Are you a boy or a girl?" = "Bist du ein Junge oder ein Mädchen?"
    "Now what did you say your name was?" = "Wie hast du gesagt, war dein Name?"
    "So you're \\PN?" = "Also bist du \\PN?"
    "What is your name?" = "Wie ist dein Name?"
    "\\PN, are you ready?" = "\\PN, bist du bereit?"
    "Your very own Pokémon story is about to unfold" = "Deine ganz eigene Pokémon-Geschichte wird sich entfalten"
    "You'll face fun times and tough challenges" = "Du wirst schöne Zeiten und schwere Herausforderungen erleben"
    "A world of dreams and adventures with Pokémon awaits! Let's go!" = "Eine Welt der Träume und Abenteuer mit Pokémon erwartet dich! Lass uns gehen!"
    "Enjoy the Starter Kit. You should give credit when using it" = "Genieße das Starter-Kit. Du solltest Anerkennung geben, wenn du es verwendest"
    "Every 1000 years a comet appears in the night sky" = "Alle 1000 Jahre erscheint ein Komet am Nachthimmel"
    "It can only be seen for 7 days until it disappears for another 1000 years" = "Er kann nur 7 Tage lang gesehen werden, bis er für weitere 1000 Jahre verschwindet"
    'The Millennium Comet.*is a special type of comet' = 'Der Jahrtausend-Komet.*ist eine besondere Art von Komet'
    "It holds an immense amount of energy" = "Er enthält eine immense Menge an Energie"
    "Some of this energy reaches earth, making contact with every living being on it" = "Ein Teil dieser Energie erreicht die Erde und macht Kontakt mit jedem Lebewesen darauf"
    'It is said that it gave birth to.*The Wishmaker' = 'Es wird gesagt, dass er.*den Wunscherfüller.*gebar'
    "Boy" = "Junge"
    "Girl" = "Mädchen"
    "Controls" = "Steuerung"
    "Adventure" = "Abenteuer"
    "No info needed" = "Keine Info benötigt"
    "I can see you calling me over there" = "Ich kann sehen, dass du mich da drüben rufst"
    "Come over and talk to me" = "Komm her und sprich mit mir"
    "So, how's your Pokédex coming along?" = "Wie läuft es denn mit deinem Pokédex?"
    "Hmm, let's see..\\nYou've seen \\v\\[1\\] Pokémon, and \\nyou've caught \\v\\[2\\] Pokémon!\\nI see!" = "Hmm, mal sehen..\\nDu hast \\v\\[1\\] Pokémon gesehen und \\ndu hast \\v\\[2\\] Pokémon gefangen!\\nIch verstehe!"
    "Hmm, you still have a long journey ahead of you! \\nKeep on going!" = "Hmm, du hast noch eine lange Reise vor dir! \\nMach weiter so!"
    "Hmm, you're catching Pokémon at a decent pace!" = "Hmm, du fängst Pokémon in einem guten Tempo!"
    "You've caught a lot of Pokémon, but make sure you're raising them carefully!" = "Du hast viele Pokémon gefangen, aber achte darauf, dass du sie sorgfältig aufziehst!"
    "I didn't even know that many Pokémon existed!" = "Ich wusste gar nicht, dass so viele Pokémon existieren!"
    "Show me your Pokédex again anytime!" = "Zeig mir deinen Pokédex jederzeit wieder!"
    "Show me your Pokédex anytime!" = "Zeig mir deinen Pokédex jederzeit!"
    "Do you want me to stop following you?" = "Willst du, dass ich aufhöre, dir zu folgen?"
    "I'll just vanish, then" = "Dann verschwinde ich einfach"
    "Let's keep going!" = "Lass uns weitermachen!"
    "Evaluate Pokédex" = "Pokédex bewerten"
}

function Translate-Text {
    param([string]$text)
    
    # Wenn die Zeile leer ist oder nur Whitespace/Kommentare enthält, nicht übersetzen
    if ([string]::IsNullOrWhiteSpace($text) -or $text.StartsWith("#") -or $text.StartsWith("[Map") -or $text.StartsWith("------")) {
        return $text
    }
    
    $translatedText = $text
    
    # Ersetze spezifische Phrasen zuerst (längere zuerst)
    $sortedKeys = $translations.Keys | Sort-Object Length -Descending
    
    foreach ($key in $sortedKeys) {
        if ($key -match '\.\*') {
            # Verwende Regex für Patterns mit .*
            $translatedText = $translatedText -replace $key, $translations[$key]
        } else {
            # Normale String-Ersetzung
            $translatedText = $translatedText.Replace($key, $translations[$key])
        }
    }
    
    return $translatedText
}

# Array für übersetzte Zeilen
$translatedLines = @()
$totalLines = $lines.Count
$currentLine = 0

Write-Host "Verarbeite $totalLines Zeilen..." -ForegroundColor Yellow

foreach ($line in $lines) {
    $currentLine++
    
    # Fortschrittsanzeige alle 1000 Zeilen
    if ($currentLine % 1000 -eq 0) {
        $progress = [math]::Round(($currentLine / $totalLines) * 100, 1)
        Write-Host "Fortschritt: $progress% ($currentLine/$totalLines)" -ForegroundColor Cyan
    }
    
    # Prüfe ob es eine gerade Zeilennummer ist (jede zweite Zeile übersetzen)
    # Beachte: Array ist 0-basiert, aber wir wollen jede zweite "logische" Zeile
    if ($currentLine % 2 -eq 0) {
        # Das ist eine zu übersetzende Zeile
        $translatedLine = Translate-Text -text $line
        $translatedLines += $translatedLine
        
        # Debug-Ausgabe für die ersten 20 Übersetzungen
        if ($currentLine -le 40) {
            Write-Host "Zeile $currentLine übersetzt:" -ForegroundColor Green
            Write-Host "  Original: $line" -ForegroundColor Gray
            Write-Host "  Deutsch:  $translatedLine" -ForegroundColor White
            Write-Host ""
        }
    } else {
        # Das ist eine englische Zeile, die unverändert bleibt
        $translatedLines += $line
    }
}

Write-Host "Speichere übersetzte Datei als $OutputFile..." -ForegroundColor Green

# Speichere die übersetzten Zeilen in eine neue Datei
$translatedLines | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Übersetzung abgeschlossen!" -ForegroundColor Green
Write-Host "Originaldatei: $InputFile" -ForegroundColor Cyan
Write-Host "Übersetzte Datei: $OutputFile" -ForegroundColor Cyan
Write-Host "Gesamt verarbeitete Zeilen: $totalLines" -ForegroundColor Cyan

# Erstelle eine Backup-Kopie der ursprünglichen Datei
$backupFile = $InputFile + ".backup"
if (-not (Test-Path $backupFile)) {
    Copy-Item $InputFile $backupFile
    Write-Host "Backup erstellt: $backupFile" -ForegroundColor Yellow
}

Write-Host "`nUm die Übersetzung anzuwenden, führe aus:" -ForegroundColor Magenta
Write-Host "Copy-Item '$OutputFile' '$InputFile'" -ForegroundColor White
Write-Host "`nOder führe das Skript mit -AutoApply aus:" -ForegroundColor Magenta
Write-Host ".\translate_pokemon_text.ps1 -AutoApply" -ForegroundColor White 