require 'fileutils'
class Evaluation
	attr_accessor :series
	def initialize
		@data = []
		@in = nil
		@series = {}
	end
	def input(file)
		@in = File.open(file,"r")
	end
	def output(file)
		@out = File.open(file,"w")
	end
	def close
		@in.close
	end
	def parse
		@in.each_line do |line|
			unless line.strip.empty?
				parr = line.strip.split(",")
				@data.push(EvalObj.new(*parr))
			end
		end
	end
	def filterby(tt,cat)
		sum = {"tc"=>0,"to"=>0,"tu"=>0,"co"=>0,"cu"=>0,"cm"=>0,"cf"=>0,"gtb"=>0,"stb"=>0}
		count = {"tc"=>0,"to"=>0,"tu"=>0,"co"=>0,"cu"=>0,"cm"=>0,"cf"=>0,"gtb"=>0,"stb"=>0}
		score = 0
		prec = 0
		@data.each do |elem|
			if (elem.tt==tt) && (elem.category==cat)
				count["tc"]+=1;count["to"]+=1;count["tu"]+=1;count["co"]+=1;count["cu"]+=1;count["cm"]+=1;count["cf"]+=1;count["gtb"]+=1;count["stb"]+=1
				sum["tc"]+=elem.tc;sum["to"]+=elem.to;sum["tu"]+=elem.tu;sum["co"]+=elem.co;sum["cu"]+=elem.cu;sum["cm"]+=elem.cm;sum["cf"]+=elem.cf;sum["gtb"]+=elem.gtb;sum["stb"]+=elem.stb
				puts "#{elem} #{cat} #{tt}"
				@out.puts elem
			end
		end
		
		@out.close
		
		avg = {}
		avg["tc"] = div(sum["tc"],count["tc"])
		avg["to"] = div(sum["to"],count["to"])
		avg["tu"] = div(sum["tu"],count["tu"])
		avg["co"] = div(sum["co"],count["co"])
		avg["cu"] = div(sum["cu"],count["cu"])
		avg["cm"] = div(sum["cm"],count["cm"])
		avg["cf"] = div(sum["cf"],count["cf"])
		avg["gtb"] = div(sum["gtb"],count["gtb"])
		avg["stb"] = div(sum["stb"],count["stb"])
		
		prec = div(avg["tc"],avg["gtb"])
		score = div(prec,avg["to"]+avg["tu"]+avg["cm"]+avg["cf"])
		
		return [avg["tc"],avg["to"],avg["tu"],avg["co"],avg["cu"],avg["cm"],avg["cf"],avg["gtb"],avg["stb"],prec,score]
	end
	
	private
	
	def div(a,b)
		if b==0
			return 0.0
		else
			return a.to_f/b.to_f
		end
	end
end

class EvalObj
	attr_accessor :url,:category,:tc,:to,:tu,:co,:cu,:cm,:cf,:tt,:gtb,:stb
	def initialize(url,category,tc,to,tu,co,cu,cm,cf,tt,gtb,stb)
		@url = url.strip
		@category = category.strip
		@tc = tc.strip.to_i
		@to = to.strip.to_i
		@tu = tu.strip.to_i
		@co = co.strip.to_i
		@cu = cu.strip.to_i
		@cm = cm.strip.to_i
		@cf = cf.strip.to_i
		@tt = tt.strip.to_i
		@gtb = gtb.strip.to_i
		@stb = stb.strip.to_i
	end
	def to_s
		"#{@url},#{@category},#{@tc},#{@to},#{@tu},#{@co},#{@cu},#{@cm},#{@cf},#{@tt},#{@gtb},#{@stb},"
	end
end

myeval = nil

cats = []
cats.push("society")
cats.push("arts")
cats.push("games")
cats.push("kids_and_teens")
cats.push("reference")
cats.push("shopping")
cats.push("world")
cats.push("business")
cats.push("health")
cats.push("news")
cats.push("regional")
cats.push("computers")
cats.push("home")
cats.push("recreation")
cats.push("science")
cats.push("sports")
cats.push("nocat")



cats.each do |category|
	
	unless File.exists? "output/#{category}"
		FileUtils.mkdir_p "output/#{category}"
	else
		FileUtils.rm_r Dir.glob("output/#{category}/*")
	end

	myeval = Evaluation.new
	["BOM","VIPS"].each do |algo|
		myeval.series[algo] = []
		myeval.input("results#{algo}data.txt")
		myeval.parse
		0.upto(5) do |i|
			tt=i*5
			myeval.output("output/#{category}/#{algo}_#{tt}.txt")
			myeval.series[algo].push [tt].concat(myeval.filterby(tt,category))
		end
		myeval.close
	end
	
	
	File.open("output/#{category}/#{category}_serie.csv","w") {|f|
		header = ["tt"] 
		["BOM","VIPS"].each do |algo|
			["tc","to","tu","co","cu","cm","cf","gtb","stb","prec","score"].each do |field|
				header.push "#{algo}_#{field}"
			end
		end
		
		f.puts header.join(";")
		
		0.upto(myeval.series["BOM"].size-1).each do |i|
			line = []
			bom_i = myeval.series["BOM"][i]
			vips_i = myeval.series["VIPS"][i]
			
			line.push bom_i[0] 
			line.push bom_i[1..(bom_i.size)].concat(vips_i[1..(vips_i.size)])
			f.puts line.join(";")
		end
		
		
	}
	
end

