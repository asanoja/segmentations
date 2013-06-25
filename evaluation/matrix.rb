class Matrix
	attr_accessor :rows
	def initialize(filas=1,cols=1,default=nil)
		@filas = filas
		@cols = cols
		@rows = Array.new(filas) {Array.new(cols) {default} }
	end
	def [](row,col)
		@rows[row][col]
	end
	def []=(row,col,value)
		@rows[row][col] = value
	end
	def row(row)
		@rows[row]
	end
	def load(file)
		tdata = File.readlines(file).collect {|x| 
			x.strip.split(" ").collect{|y| y.to_f}
		}
		i=0
		tdata.each {|r| 
			@rows[i] = r
			i+=1
		}
	end
	def save_to(file)
		File.open(file,"w") {|f|
			@rows.each {|r| 
				f.puts r.join(" ")
			}
		}
	end
	def format(x)
		if x.nil? 
			return " "*4 
		else
			if x.to_f==0.0
				return " "*4 
			else
				return "%.2f" % x
			end
		end
	end
	def to_s
		s = "row/col\t  "+(0..(@cols)).to_a.join("\t\t")+"\n"
		s+= ("-"*65)+"\n"
		i=0
		@rows.each {|r| 
			r.collect! {|x| format(x)}
			s+= "#{i} \t\t#{r.join("\t")}\n"
			i+=1
		}
		s
	end
end
