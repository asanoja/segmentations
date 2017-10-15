/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

function documentDim(win,doc) {
	var w,h;
	if (win) w=win; else win=window;
	if (doc) d=doc; else doc=document;
	return {w:$(doc).width(),h:$(doc).height()};
}


function getRect(obj) {
	if (obj.tagName.toUpperCase() == "BODY") {
		return {x:0, y:0, w:documentDim().w, h:documentDim().h}
	} else {
		//~ r=obj.getBoundingClientRect();
		return {x:$(obj).offset().left, y:$(obj).offset().top, w:$(obj).width(), h:$(obj).height()};
	}
	
}

function geometry(elem) {
    var r = getRect(elem);
    return(r.x + "," + r.y + "," + r.w  + "," + r.h); //quitar x de w ??
}

function decorate() {
    var all = document.body.getElementsByTagName("*");
    var elem;
    var ecount;
    var tcount;
    for (var i=0;i<all.length;i++) {
        elem = all[i];
        if ($.isFunction($.fn.find) ) {
			ecount = $(elem).find("*").length;
			tcount = countWords($(elem).text());
			elem.setAttribute("geometry",geometry(elem)+","+ecount+","+tcount);
		}
    }
    return(true);
}

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
