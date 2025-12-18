require "optparse"
require 'whatlanguage'

# Couleurs pour le highlight
RED   = "\e[31m"
RESET = "\e[0m"

# Options CLI
options = {
  stats: false,
  search: nil,
  tables: false
}

# Méthode pour détecter le type d'un tableau
def detect_table_type(table_lines)
  separators = {
    "PIPE" => /\s*\|\s*/,
    "CSV" => /\s*,\s*/,
    "TSV" => /\t/,
    "SEMICOLON" => /\s*;\s*/,
    "ALIGNED" => /\s{2,}/
  }

  separators.each do |type, regex|
    column_counts = table_lines.map { |line| line.split(regex).size }
    if column_counts.uniq.size == 1 && column_counts.first >= 2
      return [type, column_counts.first]
    end
  end

  ["UNKNOWN", 0]
end

# Gestion des options CLI
OptionParser.new do |opts|
  opts.banner = "Usage: ruby analyzer.rb <file> [options]"

  opts.on("--stats", "Show file statistics") do
    options[:stats] = true
  end

  opts.on("--search TERM", "Search a word or phrase") do |term|
    options[:search] = term
  end

  opts.on("--tables", "Detect tables in the file") do
    options[:tables] = true
  end

  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end.parse!

# Vérifie qu’un fichier est fourni
if ARGV.empty?
  puts "Error: please provide a file"
  exit
end 

file_path = ARGV[0]

unless File.exist?(file_path)
  puts "Erreur : le fichier '#{file_path}' n'existe pas."
  exit
end

# Initialisation des compteurs
lines_count = 0
words_count = 0
chars_count = 0
occurrences = 0
matching_lines = []

# Lecture ligne par ligne
File.foreach(file_path).with_index(1) do |line, line_number|
  lines_count += 1
  words_count += line.split.size
  chars_count += line.length

  if options[:search]
    if line.downcase.include?(options[:search].downcase)
      occurrences += line.downcase.scan(options[:search].downcase).size
      matching_lines << [line_number, line.strip]
    end
  end
end

# Affichage des stats
if options[:stats] || !options[:search].nil?
  puts "File : #{file_path}"
  puts
  puts "STATISTICS"
  puts " - Lines : #{lines_count}"
  puts " - Words : #{words_count}"
  puts " - Characters : #{chars_count}"
end

# Affichage recherche
if options[:search]
  puts
  puts "Search: \"#{options[:search]}\""
  puts "Occurrences: #{occurrences}"

  if matching_lines.any?
    puts
    puts "Lines:"
    matching_lines.each do |line_number, content|
      highlighted = content.gsub(
        /#{Regexp.escape(options[:search])}/i,
        "#{RED}\\0#{RESET}"
      )
      puts "  #{line_number}: #{highlighted}"
    end
  else
    puts "No matches found."
  end
end

# Détection de la langue
text = File.read(file_path)
lang_detector = WhatLanguage.new(:all)
language = lang_detector.language_iso(text)
puts
puts "Detected language: #{language}"

# Détection des tableaux
if options[:tables]
  tables = []
  current_table = []
  separator_regex = /(\|)|(,)|(;)|(\s{2,})/

  File.foreach(file_path) do |line|
    if line.match?(separator_regex)
      current_table << line.strip
    else
      if current_table.size >= 2
        tables << current_table
      end
      current_table = []
    end
  end
  tables << current_table if current_table.size >= 2

  puts
  puts "TABLE DETECTION"

  if tables.empty?
    puts " - No table detected"
  else
    tables.each_with_index do |table, index|
      type, columns = detect_table_type(table)
      puts
      puts "Table #{index + 1}:"
      puts "  Type: #{type}"
      puts "  Rows: #{table.size}"
      puts "  Columns: #{columns}"
    end
  end
end
