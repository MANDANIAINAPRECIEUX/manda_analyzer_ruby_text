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

 File.foreach (file_path) do |line|
    lines_count +=1
    words_count += line.split.size
    chars_count = line.length
 end


 puts "File : #{file_path}"
 puts
 puts"STATISTICS"
 puts " - Lines : #{lines_count}"
 puts " - Words : #{words_count}"
 puts " - Characters : #{chars_count}"