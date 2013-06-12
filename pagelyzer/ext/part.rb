o = File.open("urlscap.txt","w")
File.open("labels_url.txt").each do |line|
	url1 = line.strip.split(" ")[1]
	url2 = line.strip.split(" ")[2]
	url1a = url1.split("/")
	url2a = url2.split("/")
	i1 = url1a.rindex("http:")
	i2 = url2a.rindex("http:")
	url1 = url1a[(i1)..(url1a.size-1)].join("/") unless i1.nil?
	url2 = url2a[(i2)..(url2a.size-1)].join("/") unless i2.nil?
	o.puts "#{url1}" #{url2}"
end
o.close
