fin = File.open("urllist.txt") 
fout = File.open("urlplain.txt","w")
sal = []
fin.each_line do |line|
	unless line.start_with?("#") || line.strip==""
		sal.push "#{line.strip}"
	end
end

fout.puts sal.join("\n")

fout.close
fin.close
