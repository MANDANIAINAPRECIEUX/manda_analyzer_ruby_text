search_term = nil
RED   = "\e[31m"
RESET = "\e[0m"


if ARGV.include?("--search")
  index = ARGV.index("--search")
  search_term = ARGV[index + 1]
end
if ARGV.include?("--search") && search_term.nil?
  puts "Erreur: veuillez fournir un mot ou une phrase après --search"
  exit
end



if ARGV.empty?
    puts "Usage : ruby analyzer.rb <fichier.txt>"
    exit
end 
file_path = ARGV[0]

unless File.exist? (file_path)
    puts "Erreur : le fichier '#{file_path}' n'existe pas. "
    exit
end

 lines_count = 0
 words_count = 0
 chars_count = 0
 occurrences = 0
matching_lines = []

 File.foreach(file_path).with_index(1) do |line, line_number|
  lines_count += 1
  words_count += line.split.size
  chars_count += line.length

  if search_term
    if line.downcase.include?(search_term.downcase)
      occurrences += line.downcase.scan(search_term.downcase).size
      matching_lines << [line_number, line.strip]
    end
  end
end



 puts "File : #{file_path}"
 puts
 puts"STATISTICS"
 puts " - Lines : #{lines_count}"
 puts " - Words : #{words_count}"
 puts " - Characters : #{chars_count}"
 if search_term
  puts
  puts "Search: \"#{search_term}\""
  puts "Occurrences: #{occurrences}"

 if matching_lines.any?
  puts
  puts "Lines:"

  matching_lines.each do |line_number, content|
    highlighted = content.gsub(
      /#{Regexp.escape(search_term)}/i,
      "#{RED}\\0#{RESET}"
    )

    puts "  #{line_number}: #{highlighted}"
  end

else
  puts "No matches found."
end


 
end

