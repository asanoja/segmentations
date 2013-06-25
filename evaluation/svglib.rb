class SVGPage

attr_accessor :data, :image, :width, :height

def initialize(w,h)
	@data = []
	@image = ""
	@width = w
	@height = h
end
# <!-- -->

def svg_header
<<EOS
<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
    "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink" 
     xml:space="preserve"     
     width="#{@width}px" 
     height="#{@height}px" 
     ><!--    
     viewBox="0 0 #{@width} #{@height}"     
     zoomAndPan="disable"
    -->
EOS
end

def svg_footer
	"</svg>"
end

def svg_image(left,top,width,height,href)
	#href = "file://"+File.expand_path(File.join(File.dirname(".."), href))
	"<image x=\"#{left}\" y=\"#{top}\" width=\"#{width}\" height=\"#{height}\" xlink:href=\"#{href}\" preserveAspectRatio='none'/>\n"
end

def parse_geometry(node)
	ret={}
	ref = "#{node["ref"]}#{node["Ref"]}"
	pos = "#{node["pos"]}#{node["Pos"]}"
	if pos.strip == "" #es vips
		ret['left'] = 0
		ret['top'] = 0
		png = ImageSize.new(File.open($snapshot_file,'rb').read)
		ret['width'] = png.width
		ret['height'] = png.height
		return ret
	end
	a=pos.split(" ").collect{|e| e.split(":")[1]}
	if node.name == "Document"
		ret['left'] = 0
		ret['top'] = 0
		ret['width'] = a[0].to_i
		ret['height'] = a[1].to_i
	else
		ret['left'] = a[0].to_i
		ret['top'] = a[1].to_i
		ret['width'] = a[2].to_i
		ret['height'] = a[3].to_i
	end
	ret
end

def svg_text(x,y,s,color="black")
	x=x.to_i
	y=y.to_i
	unless s.nil?
s = <<EOF
<text x=\"#{x+1}\" y=\"#{y+1}\" style=\"fill:white;fill-opacity:1;stroke:white;stroke-width:2;stroke-opacity:1\">#{s}</text>
<text x=\"#{x}\" y=\"#{y}\" style=\"stroke:#{color};stroke-width:1;stroke-opacity:1\">#{s}</text>
EOF
	return s
	end
end

def svg_polygon(points,color="red",text=nil)
	s="<g>\n"
	s+="<polygon points=\"#{points}\" style=\"fill:transparent;stroke:#{color};stroke-width:4;fill-opacity:0.3;stroke-opacity:0.9\"/>\n"
	s+=svg_text points.split(",")[0],points.split(",")[1].to_i+10,text+"\n" unless text.nil?
	s+="</g>\n"
	s
end

def parse(href=nil)
	s = svg_header
	s += svg_image 0,0,@width,@height,href unless href.nil?
	data.each do |d|
		s += svg_polygon d["points"],d["color"],d["text"]
	end
	s+=svg_footer
end

end
