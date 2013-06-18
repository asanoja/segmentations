require 'nokogiri'

class Element
	attr_accessor :path
	def initialize(arr)
		@path,@left,@top,@width,@height = arr
		@path = @path.gsub("/tbody","")
	end
	def to_s
		"#{@path} @ (#{@left},#{@top},#{@width},#{@height})"
	end
end

def dameraulevenshtein(seq1, seq2)
    oneago = nil
    thisrow = (1..seq2.size).to_a + [0]
    seq1.size.times do |x|
        twoago, oneago, thisrow = oneago, thisrow, [0] * seq2.size + [x + 1]
        seq2.size.times do |y|
            delcost = oneago[y] + 1
            addcost = thisrow[y - 1] + 1
            subcost = oneago[y - 1] + ((seq1[x] != seq2[y]) ? 1 : 0)
            thisrow[y] = [delcost, addcost, subcost].min
            if (x > 0 and y > 0 and seq1[x] == seq2[y-1] and seq1[x-1] == seq2[y] and seq1[x] != seq2[y])
                thisrow[y] = [thisrow[y], twoago[y-2] + 1].min
            end
        end
    end
    return thisrow[seq2.size - 1]
end

File.open('results.csv','w')

marr=[]
xarr=[]

Dir.glob("manual/*").each do |cat|
	Dir.glob("#{cat}/*.txt").each do |page|
		catname = cat.split("/")[1]
		filename = page.split("/")[2].gsub("andres,","").gsub(".txt","").gsub(".","_").strip+".xml"
		puts xmlname = "xml/"+filename
		puts File.exists? xmlname
		exit
		next unless File.exists?(xmlname)
		puts "PAGE: #{filename}"
		doc = Nokogiri::XML(File.open(xmlname))
		xarr = []
		doc.search("//Block").each do |block|
			if block.at("Block").nil?
				epath = block.at("path")
				xarr.push Element.new(epath.inner_text.split(","))
			end
		end
		marr = File.readlines(page).collect {|x| x.strip if x.strip[0]=="/"}
		marr.delete(nil)
		marr.collect! {|x| x.split(",")}
		marr.collect! {|x| Element.new(x)}

		at = xarr.size
		mt = marr.size
		#puts "Manual: #{marr.size}"
		#puts "Auto: #{xarr.size}"

		tp = 0.0
		fp = 0.0
		fn = 0.0

		marr.each do |manual| 
			mindist = 99999999999999999999999999999
			match = nil
			xarr.each do |auto|
				dist = dameraulevenshtein(manual.path,auto.path)
				#puts "#{manual.path} - #{auto.path} : #{dist}"
				if dist<mindist
					mindist=dist
					match = auto
				end
			end
			unless match.nil?
				xarr.delete(match)
				cota = 6
				if mindist<=cota
					tp += 1.0
				elsif mindist>cota and mindist<=(cota+3)
					fp += 1.0
				else
					fn += 1.0
				end
				#puts "MATCH #{manual.path} - #{match.path} : #{mindist}"
			else
				fn += 1.0
				#puts "FAULT #{manual.path}"
			end
		end

		prec = tp/(tp+fp)
		rec = tp/(tp+fn)
		#~ if xarr.size>0 and marr.size>0
			#~ prec = (xarr.size-marr.size).abs/xarr.size.to_f
			#~ rec = (xarr.size-marr.size).abs/marr.size.to_f
		#~ else
			#~ next
		#~ end
		#~ 
		prec = 0 if prec.nan?
		rec = 0 if rec.nan?
		
		label = "failed"
		
		if prec >= 0.85
			if rec >= 0.85
				label = "perfect"
			else
				label = "satisfactory"
			end
		elsif prec >= 0.65 and prec < 0.85
			label = "satisfactory"
		else
			label = "failed"
		end
		puts "TP:#{tp} FP:#{fp} FN:#{fn} MT:#{mt} AT:#{at} PREC:#{prec} REC:#{rec} CAT:#{catname.upcase} #{label.upcase} #{xmlname.gsub(".xml",".html")}"
		
		File.open('results.csv','a') {|f|
			f.puts "#{tp};#{fp};#{fn};#{mt};#{at};#{prec};#{rec};#{catname.upcase};#{label.upcase};#{xmlname.gsub(".xml",".html")};"
		}
		File.open("results_#{catname.upcase}.csv",'a') {|f|
			f.puts "#{prec} #{rec}"
		}
		arr=File.readlines("results_#{catname.upcase}.csv").sort
		File.open("results_#{catname.upcase}.csv","w") {|f| f.puts arr}
	end
end
