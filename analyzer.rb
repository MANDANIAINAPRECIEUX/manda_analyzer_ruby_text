require "optparse"
require 'whatlanguage'

RED   = "\e[31m"
RESET = "\e[0m"

options = {
  stats: false,
  search: nil
}

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


text = File.read(file_path)
lang_detector = WhatLanguage.new(:all)
language = lang_detector.language_iso(text)
puts "Detected language: #{language}"

#fitadiavana tebleaux

if options[:tables]
  puts
  puts "TABLE DETECTION"

  current_table = []
  tables = []

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

  # Dernier tableau possible
  if current_table.size >= 2
    tables << current_table
  end

  if tables.empty?
    puts " - No table detected"
  else
    puts " - Tables detected: #{tables.size}"
    tables.each_with_index do |table, index|
      puts
      puts "Table #{index + 1}:"
      table.first(3).each do |row|
        puts "  #{row}"
      end
    end
  end
end
