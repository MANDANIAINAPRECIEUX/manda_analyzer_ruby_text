# manda_analyzer_ruby_text

Un petit outil CLI en Ruby pour analyser des fichiers texte, rechercher des mots, détecter la langue et même repérer des tableaux.

## Fonctionnalités

Statistiques du fichier : lignes, mots, caractères

Recherche de mots ou phrases : avec surlignage des résultats en rouge

Détection de la langue : anglais, français, allemand…

Détection de tableaux : CSV, PIPE, TSV, SEMICOLON, ALIGNED (et plus tard FIXED WIDTH et Markdown)

## Installation

git clone https://github.com/MANDANIAINAPRECIEUX/manda_analyzer_ruby_text.git
cd manda_analyzer_ruby_text
gem install whatlanguage

## Utilisation

| Option          | Description                                    |
| --------------- | ---------------------------------------------- |
| `--stats`       | Affiche les statistiques du fichier            |
| `--search TERM` | Recherche un mot ou une phrase dans le fichier |
| `--tables`      | Détecte les tableaux dans le fichier           |
| `-h, --help`    | Affiche l’aide                                 |
