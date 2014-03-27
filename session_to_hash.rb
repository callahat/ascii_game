require "fileutils"

#change all rhtml to html.erb
puts "Changing any references within the rhtml files to be 'session.to_hashS'"

Dir.glob("test/functional/**/*test.rb").each do |file|
  temp_file_name = file + ".tmp"

  modified = false
  temp_file = File.open(temp_file_name, "w")
  begin
    File.open(file).each_line do |line|
      if line =~ /session[\s]?$/
        printf "%-50s %s\n", file, line
        temp_file.puts line.gsub(/session[\s]?$/,"session.to_hash")
        modified = true
      else
        temp_file.puts line
      end
    end
    temp_file.close unless temp_file.closed?
    if modified
      FileUtils.mv(temp_file_name, file)
    else
      FileUtils.remove temp_file_name
    end
  ensure
    temp_file.close unless temp_file.closed?
    FileUtils.remove temp_file_name if File.exists? temp_file_name
    FileUtils.remove file + ".tmp2" if File.exists? file + ".tmp2"  
  end
end


