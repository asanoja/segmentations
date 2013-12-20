fin = File.open("urllist.txt") 
fout = File.open("urllist.js","w")
sal = []
k=0
fin.each_line do |line|
	unless line.strip==""
		if line.start_with?("#")
			sal.push "\"------------- #{line.strip.gsub("#","")} -------------\""
		else
			sal.push "\"#{line.strip}\""
		end
		k+=1
	end
	
	#~ break if k>=100
end
fout.puts "urls = ["
fout.puts sal.join(",\n")
fout.puts "];"
fout.close
fin.close
