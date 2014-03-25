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


function bfprocess(pac) {
	var gblocks = [];
	var fblocks = [];
	var tdcount = countWords($(document.body).text());
	var pagedef = [[documentDim().w,documentDim().h,tdcount]];
	for (var i = 0;i<blocks.length;i++) {
		var xpdef = blocks[i];
		if (xpdef) {
			var bid = xpdef[0];
			var x,y,w,h,count,tcount;
			x = xpdef[1][0];
			y = xpdef[1][1];
			w = xpdef[1][2];
			h = xpdef[1][3];
			count = xpdef[1][4];
			tcount = xpdef[1][5];
			
			//if (relativeArea(w,h) > pac) {
			if (true) {
				var rect = [x,y,w,h];
				gblocks.push([bid,rect,count,tcount,relativeArea(w,h)]);
				fblocks.push(new rectObj().init(window,document).build(x,y,w,h,"2px solid red","rgba(255, 0, 0, 0.5)",count+" nodes<br>ra:"+relativeArea(w,h)+"<br>text:"+tcount,undefined));
			} else {
				gblocks.push([bid,"DISCARDED",relativeArea(w,h)]);
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

function hypo(elem) {
	return(Math.sqrt(Math.pow(getRect(elem).w,2)+Math.pow(getRect(elem).h,2)));
}

function perimeter(elem) {
	return( 2*(getRect(elem).w+getRect(elem).h));
}

function area(elem) {
	return(getRect(elem).w * getRect(elem).h);
}
	
function proportion(elem) {
	return(hypo(elem));
}
	
	
function relativeArea(w,h) {
    return( (w*h) / (documentDim().w * documentDim().h));
}
	
