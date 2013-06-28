class Matrix
	attr_accessor :rows
	def initialize(filas=1,cols=1,default=nil)
		@filas = filas
		@cols = cols
		@rows = Array.new(filas) {Array.new(cols) {default} }
	end
	def n
		@filas
	end
	def m
		@cols
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
	def to_s
		s = "row/col\t  "+(0..(@cols-1)).to_a.join("\t\t")+"\n"
		s+= ("-"*65)+"\n"
		i=0
		@rows.each {|r| 
			r.collect! {|x| format(x)}
			s+= "#{i} \t\t#{r.join("\t")}\n"
			i+=1
		}
		s
	end
	
	def to_html
		s = "<table border='1'>"
		s += "<tr><td>row/col</td>"+(0..(@cols-1)).to_a.collect{|c| "<td>#{c+1}</td>"}.join+"</tr>\n"
		@rows.each_with_index {|r,i| 
			ow = r.clone.collect {|x| format(x,true)}
			s+= "<tr><td>#{i+1}</td>#{ow.collect{|c| "<td>#{c}</td>"}.join}</tr>\n"
		}
		s+="</table>"
		s
	end
	
	private
	
	def format(x,html=false)
		dec = 3
		if x.nil? 
			return "%.#{dec}f" % 0
		else
			if x.to_f==0.0
				return "%.#{dec}f" % x
			else
				if html
					return "<b>#{("%.#{dec}f" % x)}</b>"
				else
					return "%.#{dec}f" % x
				end
			end
		end
	end
end
