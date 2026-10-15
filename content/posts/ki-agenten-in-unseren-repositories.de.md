---
id: ai-agents
slug: ki-agenten-in-unseren-repositories
lang: de
date: 2026-10-14
seoTitle: Wie KI-Agenten in unseren Repositories arbeiten
description: Bei uns setzen KI-Agenten einzelne Aufgaben im Code um. Was ihre Arbeit prüft und wo ein Mensch entscheidet.
---

# Wie KI-Agenten in unseren Repositories arbeiten, und wo ein Mensch entscheidet

Wir arbeiten gern mit moderner Technik, und KI gehört dazu. In unseren Repositories setzen KI-Agenten Aufgaben im
Code um. Daraus folgt eine berechtigte Frage: Wer prüft, was dabei entsteht? Hier steht, wie wir die Arbeit
aufteilen, was sie prüft und wo ein Mensch entscheidet. Und warum am Ende ein Mensch entscheidet.

## Ein Issue, ein Agent

Jede Arbeit beginnt als Issue auf GitHub. Es beschreibt eine eng umrissene Aufgabe, nennt Akzeptanzkriterien und
verweist auf die Anforderungen der Spezifikation, die es umsetzt. Die Spezifikation liegt in einem eigenen
Repository, getrennt vom Code.

Ein Agent übernimmt genau ein Issue. Er arbeitet in einem eigenen Branch, schreibt Code und Tests und öffnet am
Ende einen Pull Request. Für Smart Contracts gibt es einen eigenen Agenten mit eigenen Regeln; andere übernehmen
den übrigen Code, Texte und Gestaltung.

## Eine zweite Sitzung liest jeden Pull Request

Ein Agent gibt seine Arbeit nicht selbst frei. Eine getrennte Sitzung liest jeden Pull Request gegen das Issue,
die Spezifikation und unsere Standards. Findet sie etwas, geht die Änderung zurück.

In den Hauptzweig kommt eine Änderung erst, wenn ein Mensch den Merge bestätigt. Allein kann das kein Agent.

## Was automatisch prüft

Dazu kommen Prüfungen, die als Skripte im Repository liegen. Sie laufen auf dem eigenen Rechner wie in der CI.
In unseren Smart-Contract-Repositories gehören unter anderem dazu:

- **Tests und Fuzz-Tests**, ohne Netzverbindung.
- **Fork-Tests.** Sie laufen gegen eine Kopie echter Chains an einem festen Block und rufen dort die Smart
  Contracts auf, die wirklich bereitgestellt sind, etwa Preisfeeds.
- **Statische Analyse** mit Slither und Aderyn. Jeder Befund braucht einen Eintrag in einer Liste, die ihn
  bewertet. Ein neuer Befund ohne Eintrag lässt die Prüfung scheitern.
- **Kein fremder Quelltext.** Protokolle wie Safe oder Aave rufen wir über eigene Schnittstellendateien auf.
  Ihr Quelltext wird nicht kopiert und nicht eingebunden, auch nicht in Tests, denn ihre Lizenzen passen nicht zu
  unserer. Eine Prüfung schlägt bei jedem solchen Import fehl.
- **Neue Funktionen, die Zustand ändern,** fallen auf, bis jemand bewusst entschieden hat, dass sie dazugehören,
  und sie in eine Liste einträgt.
- **Abhängigkeiten** werden gegen unsere Lizenzregeln und bekannte Schwachstellen geprüft, und es entsteht eine
  Softwarestückliste (SBOM).
- **Ein Scan nach Geheimnissen** durchsucht Dateien und Historie nach Schlüsseln und Zugangsdaten.
- **Eine Liste verbotener Formulierungen** prüft die öffentlichen Texte, etwa auf Garantieversprechen oder auf den
  Anschein einer Partnerschaft mit den Anbietern, deren Daten wir lesen.

## Was einem Menschen vorbehalten bleibt

Manche Schritte bleiben in unseren Repositories einem Menschen vorbehalten. Die Befehle zum Bereitstellen und zum
Signieren sind in den Einstellungen der Agenten gesperrt:

- Sie stellen keine Smart Contracts bereit und senden keine Transaktion an ein echtes Netz.
- Sie veröffentlichen keine Pakete und setzen keine Release-Tags.
- Jeden Merge und jedes Schließen eines Issues bestätigt ein Mensch.
- Sie halten keinen Schlüssel. Kein Schlüssel, kein Geheimnis und keine RPC-Adresse mit Zugangsschlüssel kommt ins
  Repository, auch nicht in eine Commit-Nachricht oder ein Log.

Eine Ausnahme gibt es, und sie ist eng gefasst. In einem Repository dürfen Agenten Transaktionen an eine lokale
Demo-Chain auf unserem eigenen Rechner senden. Dafür nutzen sie einen der öffentlich bekannten Testschlüssel, die
auf keinem echten Netz etwas besitzen. Ein Skript prüft vor der ersten Transaktion, dass das Ziel wirklich diese
lokale Kopie ist, und bricht sonst ab. Die Demo-Chain läuft unter einer eigenen Chain-ID, damit nichts, was dort
signiert wird, auf dem echten Netz gilt.

## Warum am Ende ein Mensch entscheidet

Bestandene Prüfungen beweisen nicht, dass Code richtig ist. Sie zeigen nur, dass er die Fehler nicht hat, nach
denen wir suchen. Agenten machen Fehler, und eine Review findet nicht jeden.

Auch die Prüfungen blockieren einen Merge nicht von selbst. Wer den Pull Request prüft, liest ihre Ergebnisse vor
dem Merge. Ein Pull Request, für den keine CI gelaufen ist, gilt nicht als bestanden.

Deshalb entscheidet am Ende ein Mensch. Jeden Merge bestätigt ein Mensch, und jede Bereitstellung auf einer Chain
machen wir von Hand. Vor einem Release liest ein eigener Prüf-Agent die Smart Contracts mit dem Blick eines
Angreifers und meldet, was er findet; er behebt nichts und bescheinigt nichts. Sieht unser Plan für ein Projekt
ein externes Audit vor, findet es vor dem Release statt.

Unsere Smart Contracts lassen sich nach der Bereitstellung nicht mehr ändern. Eine Korrektur ist immer eine neue
Version. Darum zählt all das vorher.

## Warum wir das aufschreiben

Wer unsere Arbeiten nutzt, fördert oder über sie schreibt, soll beurteilen können, wie sie entstehen. Die Regeln
oben stehen in den Repositories selbst: in den Anweisungen für Agenten und in der Datei `CONTRIBUTING.md`. Sobald
ein Repository öffentlich ist, können Sie sie dort nachlesen.
