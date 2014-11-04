var bfversion = 1;

function isLetter(c) {
	c=c.toUpperCase();
	return ( (c > "A") && (c < "Z") && (!c.match(/^\wAEIOUaeiouÀÈÌÒÙàèìòùÁÉÍÓÚÝáéíóúýÂÊÎÔÛâêîôûÃÑÕãñõÄËÏÖÜäëïöüçÇßØøÅåÆæÞþÐð$/))); 
}

function countWords2(s){
    var wordCount = 0;
    var word = false;
    var endOfLine = s.length - 1;
    for (i=0; i<s.length;i++) {
        if (isLetter(s.charAt(i)) && i != endOfLine) {
            word = true;
        } else if (!isLetter(s.charAt(i)) && word) {
            wordCount++;
            word = false;
        } else if (isLetter(s.charAt(i)) && i == endOfLine) {
            wordCount++;
        }
    }
    return wordCount;
}
function countWords(txt) {
	if ($.trim(txt)=="") 
		return(0);
	else
		return txt.replace( /[^\w ]/g, "" ).split( /\s+/ ).length
}

Array.prototype.equals = function (array) {
    // if the other array is a falsy value, return
    if (!array)
        return false;

    // compare lengths - can save a lot of time 
    if (this.length != array.length)
        return false;

    for (var i = 0, l=this.length; i < l; i++) {
        // Check if we have nested arrays
        if (this[i] instanceof Array && array[i] instanceof Array) {
            // recurse into the nested arrays
            if (!this[i].equals(array[i]))
                return false;       
        }           
        else if (this[i] != array[i]) { 
            // Warning - two different object instances will never be equal: {x:20} != {x:20}
            return false;   
        }           
    }       
    return true;
}

Array.prototype.unique = function() {
    var arr = [];
    for(var i = 0; i < this.length; i++) {
        var exist=false;
        for (var j=0;j<arr.length;j++) {
            if (arr[j].equals(this[i])) {
                exist=true;
                break;
            }
        }
        if (!exist && this[i]) arr.push(this[i]);
    }
    
    return arr; 
}

function getPolygonPoints(rect) {
    var res = [];
    res = res.concat([rect[0], rect[1]]);
    res = res.concat([rect[0], rect[1] + rect[3]]);
    res = res.concat([rect[0] + rect[2], rect[1] + rect[3]]);
    res = res.concat([rect[0] + rect[2], rect[1]]);
    return(res);
}

function bfprocess(pac) {
	var gblocks = [];
	var fblocks = [];
	var tdcount = countWords($(document.body).text());
	var pagedef = [[documentDim().w,documentDim().h,tdcount]];
        var list = blocks.unique();
	for (var i = 0;i<list.length;i++) {
		var block = list[i];
		if (block) {
			var bid = block[0];
                        var geom = block;
                        geom.shift();
                        geom=geom.unique();
                        for (var j=0;j<geom.length;j++) {
                            var g = geom[j];
                            if (g) {
                                if (g[0]) {
                                    var x,y,w,h,count,tcount;
                                    x = g[0];
                                    y = g[1];
                                    w = g[2];
                                    h = g[3];
                                    count = g[4];
                                    tcount = g[5];
                                    var rect = [x,y,w,h];
                                    var over = false;
                                    for (var i=0;i<gblocks.length;i++) {
                                        var pb = getPolygonPoints(gblocks[i][1]);
                                        if (PolyK.ContainsPoint(pb,rect[0],rect[1])) {
                                            over=true;
                                        }
                                        
                                    }
                                    if (!over) {
                                        gblocks.push([bid,rect,count,tcount,relativeArea(w,h)]);
                                        fblocks.push(new rectObj().init(window,document).build(x,y,w,h,"2px solid red","rgba(255, 0, 0, 0.5)",count+" nodes<br>ra:"+relativeArea(w,h)+"<br>text:"+tcount,undefined));                                            
                                    }
                                }
                            }
                        }
                }
			
	}
	pagedef.push(gblocks);
	return(pagedef);
}

function documentDim(win,doc) {
	var w,h;
	if (win) w=win; else win=window;
	if (doc) d=doc; else doc=document;
	return {w:$(doc).width(),h:$(doc).height()};
}

function normW(obj) {
        return 100 * getRect(obj).w / documentDim().w;
    }
function normH(obj) {
        return 100 * getRect(obj).h / documentDim().h;
    }

function normarea(obj) {
        var cont = 0;
        for (var i = 0; i < 100; i += 10) {
            if (normW(obj) > i)
                cont++;
        }
        var dw = cont;
        cont = 0;
        for (var i = 0; i < 100; i += 10) {
            if (normH(obj) > i)
                cont++;
        }
        var dh = cont;

        var d = (dw * dh) * 10 / 100;
        return(d);
    }

function relativeArea(obj) {
    if (!obj) return(0);
    return(normarea(obj));
}


function getRect(obj) {
    if (!obj) return {x:0,y:0,w:0,h:0};
    if (!obj.tagName) return {x:0,y:0,w:0,h:0};
    if (obj.tagName.toUpperCase() == "BODY") {
        return {x: 0, y: 0, w: documentDim().w, h: documentDim().h}
    } else {
        //~ r=obj.getBoundingClientRect();
        return {x: $(obj).offset().left, y: $(obj).offset().top, w: $(obj).width(), h: $(obj).height()};
    }

}
