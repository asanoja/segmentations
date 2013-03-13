require './parse_page.rb'

v = []

["news","sport","entertaiment","synthetic"].each do |c|
	v.push parse(c,ARGV[0],"output/wp")
end

p v
m = ""
mv = 0.0

v.each{|x| 
	c = x.split(":")
	if c[1].to_f > mv.to_f
		m = x
		mv = c[1]
	end
}
puts cat = m.split(":")[0]




