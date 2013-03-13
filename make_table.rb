require './matrix.rb'

cat = ARGV[0]

tags = ARGV[1..(ARGV.size-1)]
if tags.join=="all"
	tags = File.open("taglist.txt").readlines.collect {|e| e.split(" ")[0].strip}.flatten
end

tags.each do |tag|

	frec = Matrix.new(7,7,0)
	total = Matrix.new(7,7,0)
	prob = Matrix.new(7,7,0)

	File.open("data/#{cat}/#{tag}.csv") { |f|
		f.each_line do |line|
			 nsection,nlevel = line.strip.split(",").collect {|num| num.to_f}
			 frec[nsection.round,nlevel.round] += 1
		end
	}
	
	
	puts "\nAbsolute Frequency table in #{cat} for #{tag} tag"
	puts frec.to_s
	
	total.load("data/#{cat}/#{cat}_total.dat")
	puts "\nTags total frequency table in #{cat}"
	puts total.to_s
	
	0.upto(6) do |nsection|
		0.upto(6) do |nlevel|
			if total[nsection,nlevel].to_f != 0.0
				prob[nsection,nlevel] = frec[nsection,nlevel].to_f / total[nsection,nlevel].to_f
			else
				prob[nsection,nlevel] = 0.0
			end
		end
	end
	
	puts "\nRelative frequency table in #{cat} for #{tag} tag"
	puts prob.to_s
	prob.save_to("data/#{cat}/#{tag}.prob")
		
end
