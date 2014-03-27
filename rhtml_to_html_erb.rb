require "fileutils"

#change all rhtml to html.erb
puts "Changing any references within the rhtml files to be 'html.erb'"

Dir.glob("app/views/**/*rhtml").each do |file|
  temp_file_name = file + ".tmp"

  modified = false
  temp_file = File.open(temp_file_name, "w")
  begin
    File.open(file).each_line do |line|
      if line =~ /rhtml/i
        printf "%-50s %s\n", file, line
        temp_file.puts line.gsub(/rhtml/i,"html.erb")
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
    `svn rename #{file} #{file.gsub(/\.rhtml/i, ".html.erb")}`
  ensure
    temp_file.close unless temp_file.closed?
    FileUtils.remove temp_file_name if File.exists? temp_file_name
    FileUtils.remove file + ".tmp2" if File.exists? file + ".tmp2"  
  end
end


