var tabularList = ["TABLE", "TD"]
var containerList = ["BODY", "DIV", "UL", "DL", "P", "OBJECT", "IFRAME", "INS"];
var contentList = ["SPAN", "A", "LI", "DT", "DD", "H1", "H2", "H3", "H4", "H5", "IMG", "INS", "INPUT", "P","PRE","TT"];
var excludeList = ["SCRIPT", "STYLE", "AREA", "HEAD", "META", "FRAME", "FRAMESET", "BR", "HR", "NOSCRIPT","TITLE"];
var ignoreList = ["HTML", "TBODY", "TR", "PARAM", "LINK", "COLGROUP"];
var semanticList = ["SECTION", "HEADER", "FOOTER", "ASIDE", "NAV", "ARTICLE"]

var gridRows = 20; //horizontal partition grid
var gridCols = 10; //vertical partition grid
var grid;

var ac = 5; //0 small blocks <--> 10 big blocks
var dc = 50; //50px max separation distance between blocks for merging process
var tc = 1; //minimum characters to be consider a valid text element not WS or valid innertext string

var dx = dc; //max distance between blocks and page boundaries 
var dy = dc; // used to determine labels to logic objects. Using DC parameter as default.

var blocks = []; //list of all logic objects (blocks)
var geoList = []; //list if all geometric objects (content)

var bomversion = "1.1";

var colors = {PAGE: '#FFFF00', CONTAINER: '#FF0000', CONTENT_CONTAINER: '#FF0000', CONTENT: 'FF0000', DEFAULT: 'FF0000', TABULAR: 'FF0000'};

var root // DOM top object
var page; //page logical object
var georoot; //top content object

var verbose = true; //for debugging. Write DIVS representing blocks  in live web page.
var showGrid = false; //if true and verbose=true it allows to show the grid to compute importances

/*
 * main function call to perform segmentation
 * win: the browser window object, frame, etc.
 * pac: parameter of granularity
 * pdc: distance parameter of separation between blocks (used for merging)
 * proclog: process logic structure. True for automatic segmentation
 */
function startSegmentation(win, pac, pdc, returnType, psourceurl) {
    contentWindow = win;
    contentDocument = contentWindow.document;
    ac = pac;
    dc = pdc;
    debug("Starting with AC:" + ac + ", DC:" + dc + "px, return:" + returnType);
    root = contentDocument.getElementsByTagName('BODY')[0];
    debug("Processing Content Structure");
    processContentStructure(root, 0);
    debug("Processing Geometric Structure");
    georoot = processGeometricStructure(root, undefined);
    debug("Pre-processing Logic Structure");
    page = prepareLogicStructure(georoot);
    debug("Processing Logic Structure");
    processLogicStructureMain(page, 0, 1, undefined);
    buildGrid();
    processImportance(page);
    //clearGrid();
    setLabels(page);
    switch(returnType.toLowerCase()) {
        case "vixml": return(getViXML());break;
        case "wprima": return(getWPrima(page));break;
        case "record": return(getRecord(page,""));break;
        case "descriptor": return(getDescriptor(page,""));break;
        default: return(getViXML());break;
    }
}


function setLabels(block) {
	block.setLabel();
	//~ for (var i=0;i<blocks.getChildren();i++) {
	for (var i=0;i<block.children.length;i++) {
		var b = block.children[i];
		if (b) {
			setLabels(b);
		}
	}
}

/* escape special characters from link title */
function code(s) {
    var res = "";
    if (!s)
        return "";
    res = s.replace(/&/g, "&amp;");
    res = res.replace(/'/g, "&#39;");
    res = res.replace(/"/g, "&quot;");
    res = res.replace(/>/g, "&gt;");
    res = res.replace(/</g, "&lt;");
    return res;
}

/* get ViXML document */
function getViXML() {
    var cnt = "<XML>\n";
    cnt += "<Document url='" + (document.URL) + "' Title='" + code(document.title) + "' Version='" + bomversion + "' Pos='WindowWidth||PageRectLeft:" + documentDim().w + " WindowHeight||PageRectTop:" + documentDim().h + " ObjectRectWith:0 ObjectRectHeight:0'>\n";
    cnt += getViXMLObject(page, 0, 1);
    cnt += "</Document>\n";
    cnt += "</XML>";
    return(cnt);
}

/* get the image list of a block */
function getImageList(obj) {
    var t = "<Imgs ID='#ID#' IDList='$ID_LIST_IMAGES$'>\n";
    var a = "";
    var list = [];
    var col = [];

    for (var m = 0; m < obj.geometricObjects.length; m++) {
        var geo = obj.geometricObjects[m];

        axc = obj.geometricObjects[m].element.getElementsByTagName("img");
        //alert("img " +axc.length);
        for (p = 0; p < axc.length; p++) {
            col.push(axc[p]);
        }

        axc = obj.geometricObjects[m].element.getElementsByTagName("input");
        //alert("input " +axc.length);
        for (p = 0; p < axc.length; p++) {
            if (axc[p].type == "image") {
                col.push(axc[p]);
            }
        }
    }

    col = col.filter(function(elem, pos) {
        return col.indexOf(elem) == pos;
    });

    for (var i = 0; i < col.length; i++) {
        var img = col[i];
        var pt = img.getAttribute("alt");
        a = "<img ID='#ID#' Name=\"" + code(pt) + "\" Src='" + code(img.getAttribute('src')) + "'/>"
        var c = CryptoJS.MD5(a);
        list.push(c);
        t += a.replace('#ID#', c) + "\n";
    }
    t += "</Imgs>\n";
    t = t.replace('$ID_LIST_IMAGES$', list.join(","));
    t = t.replace("#ID#", CryptoJS.MD5(t));
    return(t);
}

/* get the link list of a block */
function getLinksList(obj) {
    var t = "<Links ID='#ID#' IDList='$ID_LIST_LINKS$'>\n";
    var a = "";
    var list = [];
    var col = [];
    for (var m = 0; m < obj.geometricObjects.length; m++) {
        var geo = obj.geometricObjects[m];
        axc = obj.geometricObjects[m].element.getElementsByTagName("a");

        for (p = 0; p < axc.length; p++) {
            col.push(axc[p]);
        }
    }
    col = col.filter(function(elem, pos) {
        return col.indexOf(elem) == pos;
    });

    for (var i = 0; i < col.length; i++) {
        var link = col[i];
        var pt = $(link).text();
        a = "<link ID='#ID#' Name=\"" + code(pt) + "\" Adr='" + code(link.getAttribute('href')) + "'/>"
        var c = CryptoJS.MD5(a);
        list.push(c);
        t += a.replace('#ID#', c) + "\n";
    }
    t += "</Links>\n";
    t = t.replace('$ID_LIST_LINKS$', list.join(","));
    t = t.replace("#ID#", CryptoJS.MD5(t));
    return(t);
}

/* get text nodes recursively in a block */
function collectTextNodes(element, texts) {
    if (element.tagName.toLowerCase() == "script")
        return;

    for (var child = element.firstChild; child !== null; child = child.nextSibling) {
        if (child.nodeType === 3)
            texts.push(child);
        else if (child.nodeType === 1)
            collectTextNodes(child, texts);
    }
}

/* get text nodes recursively in a block */

function getTextWithSpaces(element) {
    if (element.tagName.toLowerCase() == "script")
        return "";
    var texts = [];
    collectTextNodes(element, texts);
    for (var i = texts.length; i-- > 0; )
        texts[i] = texts[i].data.replace("'", "").replace('"', "").replace("&", "&amp;");
    return texts.join(' ');
}

function getText(obj) {
    var all = "";
    for (var i = 0; i < obj.geometricObjects.length; i++) {
        var geo = obj.geometricObjects[i];
        if (geo) {
            if (!isExcluded(geo.element)) {
                $(geo.element).find('script').remove();
                all += getTextWithSpaces(geo.element)
            }

        }
    }


    all = all.replace(/<[^>]+>/ig, "");
    all = all.replace(/\s+/g, ' ');
    all = code(all);
    var txt = "<Txts ID=\"" + CryptoJS.MD5(all) + "\" Txt=\"" + all + "\"/>";
    return(txt);
}



/* get ViXML for a block */
function getViXMLObject(obj, level, pid) {
    if (!obj)
        return;
    var xml = "";
    var block = "";
    var internal = "";

    var spc = "";

    for (var j = 0; j < level; j++)
        spc += " ";


    if (obj.terminal()) {
        internal = getLinksList(obj);
        internal += spc + getImageList(obj);
        internal += spc + getText(obj);
        block += spc + "<Block Ref='Block" + pid + "' leafblock='1' internal_id='" + obj.label + "' ID='" + CryptoJS.MD5(internal) + "' Pos='WindowWidth||PageRectLeft:" + obj.dim.x + " WindowHeight||PageRectTop:" + obj.dim.y + " ObjectRectWidth:" + obj.dim.w + " ObjectRectHeight:" + obj.dim.h + "' Doc='' importance='" + obj.importance + "'>\n"
        block += internal;
    } else {
        var tt = spc + "<Block Ref='Block" + pid + "' internal_id='" + obj.label + "' ID='#ID#' Pos='WindowWidth||PageRectLeft:" + obj.dim.x + " WindowHeight||PageRectTop:" + obj.dim.y + " ObjectRectWidth:" + obj.dim.w + " ObjectRectHeight:" + obj.dim.h + "' Doc=''>\n"
        block += tt.replace("#ID#", "");
    }
    xml += block;
    for (var j = 0; j < obj.children.length; j++) {
        block = obj.children[j];
        if (block) {
            xml += getViXMLObject(block, level + 1, pid + "." + j);
        }
    }

    xml += spc + "</Block>\n"
    return(xml);
}

/*
 * Get document geometry width and height;
 * */
function documentDim(win, doc) {
    var w, h;
    if (win)
        w = win;
    else
        win = window;
    if (doc)
        d = doc;
    else
        doc = document;
    return {w: $(doc).width(), h: $(doc).height()};
}

/* count the children of an element */
function elementCount(element) {
    if (!element)
        return;
    if (isWS(element))
        return;
    if (isComment(element))
        return;
    if (isText(element))
        return;

    var count = 0;
    for (var i = 0; i < obj.childNodes.length; i++) {
        var child = obj.childNodes[i];
        if (child && !isWS(child) && !isComment(child) && !isText(child))
            count++;
    }
    return(count)
}

/* 
 * count the children of a block
 * onlyLeaves=true count only leaves or terminal blocks
 */
function blockCount(obj, onlyLeaves) {
    if (!obj)
        return;
    if (!obj.block)
        return;
    var count;
    if (onlyLeaves && countChildren(obj) > 0)
        count = 0;
    else
        count = 1;

    for (var i = 0; i < obj.children.length; i++) {
        if (obj && obj.block) {
            dat = blockCount(obj.children[i], onlyLeaves);
            if (dat) {
                count += dat
            }
        }
    }
    return(count);
}

/*
 * build logic objects in base of geometric objects go's
 */
function prepareLogicStructure(go, parent) {
    if (!go)
        return;
    var log, gchild, lchild;
    log = parent;
    if ((go.children.length == 1) && (go.type !="PAGE")) {
        log = prepareLogicStructure(go.children[0], parent);
    } else {
        if ((included(go.type, ["PAGE", "CONTAINER", "CONTENT_CONTAINER", "CONTENT", "DEFAULT", "TABULAR"])) && (go.geometry))
        {
			if ( (go.geometry.x<0 || go.geometry.w<=0) || (go.geometry.y<0 || go.geometry.h<=0) ) {
			} else {
				log = createNewLogicalObject(go, parent);
			}
        }
        for (var i = 0; i < go.children.length; i++) {
            gchild = go.children[i];
            prepareLogicStructure(gchild, log);
        }
    }
    return(log);
}


/*
 * used for debuging in local javascript console 
 */
function debug(s) {
    console.log(s);
}



/*
 * used to send segmentation results to a remote server
 */
function post_to_url(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for (var key in params) {
        if (params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);
            form.appendChild(hiddenField);
        }
    }
    outputDocument.body.appendChild(form);
    form.submit();
}

/* build the xpath of an element */
function getXPath(elt) {
    var path = "";
    for (; elt && elt.nodeType == 1; elt = elt.parentNode)
    {
        idx = getElementIdx(elt);
        xname = elt.tagName;
        if (idx > 1)
            xname += "[" + idx + "]";
        path = "/" + xname + path;
    }
    return path.toLowerCase();
}

/* auxiliar function of xpath one*/
function getElementIdx(elt)
{
    var count = 1;
    for (var sib = elt.previousSibling; sib; sib = sib.previousSibling)
    {
        if (sib.nodeType == 1 && sib.tagName == elt.tagName)
            count++
    }

    return count;
}

/*
 * get the absolute position of an element.
 * */

function getRect(obj) {
	if (!obj) return({x: 0, y: 0, w: 10, h: 10,r:10,b:10})
    if (obj.tagName.toUpperCase() == "BODY") {
        return {x: 0, y: 0, w: documentDim().w, h: documentDim().h,r:documentDim().w,b:documentDim().h}
    } else {
        //~ r=obj.getBoundingClientRect();
        return {x: $(obj).offset().left, y: $(obj).offset().top, w: $(obj).width(), h: $(obj).height(),r:$(obj).offset().left+$(obj).width(),b:$(obj).offset().top+$(obj).height()};
    }

}

/*is an element a text node? */
function isText(element) {
    if (element) {
        if (element.nodeName == "#text") {
            return(element.data.trim() != "");
        } else
            return(false);
    } else {
        return(false);
    }
}

/*is an element a whitespace? */
function isWS(element) {
    if (element) {
        if (element.nodeType == 3) {
            if (element.data) {
                return(element.data.trim() == "");
            } else {
                return false
            }
        } else {
            return false;
        }
    } else {
        return(false);
    }
}

/*is an element a comment node? */
function isComment(element) {
    if (element) {
        if (element.nodeType == 8) {
            return true;
        } else {
            return false;
        }
    } else {
        return(false);
    }
}

/*is an element the root element? */
function isRoot(element) {
    if (element) {
        if (element.tagName.toUpperCase() == "BODY") {
            return true;
        } else {
            return false;
        }
    } else {
        return(false);
    }
}

/*belongs an element to the content-container category ? */
function isContentContainer(element) {
    if (!element)
        return;
    if (isContainer(element)) {
        var etc = 0;
        var child;
        var n = element.childNodes.length;
        for (var i = 0; i < element.childNodes.length; i++) {
            child = element.childNodes[i];
            if (isContent(child)) {
                etc++;
            }
            if (isWS(child) || isComment(child) || !visible(child) || isExcluded(child) || isIgnored(child)) {
                n--;
            }
        }
        return(etc == n);
    } else {
        return(false);
    }
}

/*belongs an element to the default category ? */
function isDefault(element) {
    if (element.childNodes.length == 0) {
        return(true)
    }
    var ws = 0;
    for (var i = 0; i < element.childNodes.length; i++) {
        if (isWS(element.childNodes[i])) {
            ws++;
        }
    }
    return(element.childNodes.length == ws);
}

/*belongs an element to the content category ? */
function isContent(element) {
    if (!element)
        return;
    if (!element.tagName)
        return;
    if (isWS(element))
        return(false);
    if (isComment(element))
        return(false);
    if (isText(element))
        return(true);
    var itis = false;
    for (var i = 0; i < contentList.length; i++) {

        if (contentList[i].toUpperCase() == element.tagName.toUpperCase()) {
            itis = true;
            break;
        }
    }
    return(itis);
}

function isIn(element, list) {
    if (!element)
        return;
    if (!element.tagName)
        return;
    if (isWS(element))
        return(false);
    if (isComment(element))
        return(false);
    if (isText(element))
        return(true);
    var itis = false;
    for (var i = 0; i < list.length; i++) {

        if (list[i].toUpperCase() == element.tagName.toUpperCase()) {
            itis = true;
            break;
        }
    }
    return(itis);
}

function isSemantic(element) {
    return(isIn(element, semanticList));
}

/*belongs an element to the container category ? */
function isContainer(element) {
    return(isIn(element, containerList));
}

/*is the element excluded of processing? */
function isExcluded(element) {
    return(isIn(element, excludeList));
}

/*is the element ignored in processing? */
function isIgnored(element) {
    return(isIn(element, ignoreList));
}

/*is the element in tabular category? */
function isTabular(element) {
    return(isIn(element, tabularList));
}

/*which category the element belongs */
function BOMType(element) {
    if (!element)
        return(null);
    if (isWS(element))
        return(null);
    if (isComment(element))
        return(null);
    if (isText(element))
        return(null);
    if (isExcluded(element))
        return(null);
    if (!visible(element))
        return(null);
    if (!isContent(element)) {
        var txn = $(element).text();
        if (txn) {
            if ((element.children.length == 0) && (txn.trim() == "")) {
                return(false);
            }
        }
    }
    //this bother on chrome evaluation with this pluging
    if (element.getAttribute("id")) {
        if (element.getAttribute("id").toLowerCase() == "window-resizer-tooltip")
            return false;
    }
    if (isRoot(element))
        return "PAGE";
    if (isDefault(element))
        return "DEFAULT";
    if (isContent(element))
        return "CONTENT";
    if (isContentContainer(element))
        return "CONTENT_CONTAINER";
    if (isContainer(element))
        return "CONTAINER";
    if (isTabular(element))
        return "TABULAR"

    return(null);
}

/*build the content structure DOM -> geometric objects */
function processContentStructure(element, level) {
    if (!element)
        return;
    if (isWS(element))
        return(false);
    if (isComment(element))
        return(false);
    if (isText(element)) {
        if (element.parentElement.childElementCount == 0)
            return;
        else {
            var span = contentDocument.createElement("span");
            span.setAttribute("class", "bomwrapper");
            var par = element.parentNode;
            span.appendChild(element);
            par.appendChild(span);
            element = span;
            //~ element.setAttribute("bomtype", "CONTENT");
            return;
        }
    }

    //~ if (element.getAttribute("bomtype"))
        //~ return(false);
    if (isExcluded(element))
        return(false);
    if (!visible(element))
        return(false);
    if (!valid(element))
        return(false);
    if (element.getAttribute('id') == "window-resizer-tooltip")
        return(false);
    if (element.getAttribute('class') == "bommarco") 
		return(false);
    if (isIgnored(element)) {
        for (var i = 0; i < element.childNodes.length; i++) {
            processContentStructure(element.childNodes[i], level + 1);
        }
        return;
    }

    var tn = element.tagName;
    var bt = BOMType(element);
    //~ element.setAttribute("bomtype", bt);
    for (var i = 0; i < element.childNodes.length; i++) {
        processContentStructure(element.childNodes[i], level + 1);
    }
}

/*refName -> name class#id */
function refName(element) {
    if (!element)
        return "";
    if (isWS(element))
        return("");
    if (isComment(element))
        return("");
    if (isText(element))
        return("");
    if (isExcluded(element))
        return("");
    var name = "(nodef)";
    if (element.tagName)
        name = element.tagName;
    if (element.getAttribute("id"))
        name = name + "." + element.getAttribute("id");
    if (element.className)
        name = name + " " + element.className
    return(name);
}

/*process a geometric object*/
function processGeometricObject(element) {
	// TODO: revisar para usar geometric objects etc y no usar la funcion relativeareaelement
    var bt = BOMType(element);
    var geo;
    if (bt) {
        //~ element.setAttribute("bomtype", bt);
        var dim = getRect(element);
        var r = dim.x + " " + dim.y + " " + dim.w + " " + dim.h;
        var a = relativeAreaElement(element);
        //~ element.setAttribute("bomgeometry", r);
        //~ element.setAttribute("bomarea", a);
        //~ element.setAttribute("bomid", "C" + (1000 + Math.random(1000)));
        geo = createNewGeometricObject(element, element.parent);
    }
    return(geo);
}

/* process the geometric structure */
function processGeometricStructure(element, parent) {
    if (!element) {
		console.log(element+" skipped. no element")
        return;
	}
    if (isWS(element)) {
		console.log(element+" skipped. is WS")
        return(false);
	}
    if (isComment(element)) {
		console.log(element+" skipped. is comment")
        return(false);
	}
    if (isText(element)) {
		console.log(element+" skipped. is text")
        return(false);
	}
    if (isExcluded(element)) {
		console.log(element+" skipped. is excluded")
        return(false);
	}

    var dim = getRect(element);
    if ((dim.w == 0) && (dim.h == 0)) {
        //SKIP IT DO NOT CREATE GEOMETRIC OBJECT
        return;
    }
    var geo;
    if (!isIgnored(element)) {
        geo = createNewGeometricObject(element, parent);
    } else {
		console.log(element+" skipped. is in ignored list")
	}

    for (var i = 0; i < element.childNodes.length; i++) {
        var child = element.childNodes[i];
        if (!isWS(child) && !isComment(child) && !isText(child) && !isExcluded(child)) {
            if (geo)
                processGeometricStructure(child, geo);
            else
                processGeometricStructure(child, parent);
        } else {
			console.log(child+" skipped. in geometric structure")
		}
    }
    return geo;
}

/* is visual cues present: bold, font sizes, background colors, etc.*/
function visuallyDifferent(element) {
    if (element) {
        if (!included(element.style.backgroundColor.toLowerCase(), ["", "transparent", "rgba(0,0,0,0)"])) {
            return(true);
        }
    }
    return(false);
}

/* get set of points of block geometry*/
function getPolygonPoints(dim) {
    var res = [];
    res = res.concat([dim.x, dim.y]);
    res = res.concat([dim.x, dim.y + dim.h]);
    res = res.concat([dim.x + dim.w, dim.y + dim.h]);
    res = res.concat([dim.x + dim.w, dim.y]);
    return(res);
}

/* get set of X-axis of block geometry*/
function getX(points) {
    var x = [];
    for (var i = 0; i < points.length; i += 2) {
        x.push(points[i]);
    }
    return(x);
}

/* get set of Y-axis of block geometry*/
function getY(points) {
    var y = [];
    for (var i = 1; i < points.length; i += 2) {
        y.push(points[i]);
    }
    return(y);
}

/* is an element already visited */
function visited(element) {
    if (!element)
        return(true);
    var res;
    if (res = element.getAttribute("visited")) {
        if (res == "true") {
            return(true);
        } else {
            return(false);
        }
    } else {
        return(false);
    }
}


/*is an element visible?*/
function visible(obj) {
    if (isWS(obj))
        return(false);
    if (isComment(obj))
        return(false);
    if (isText(obj))
        return(true);
    if (isExcluded(obj))
        return(false);

    var xvis = true;
    var xarea = parseFloat((Math.abs(getRect(obj).w - getRect(obj).x)) * (Math.abs(getRect(obj).h - getRect(obj).y)));
    if (obj.style) {
        xvis = (included(obj.style.visibility.toUpperCase(), ["", "VISIBLE", "INHERIT"])) && (!included(obj.style.display.toUpperCase(), ["NONE"]));
    }
    return(xvis && (xarea > 0));
}

/*is an element valid?*/
function valid(obj) {
    if (isExcluded(obj))
        return(false);
    if (isComment(obj))
        return(false);
    var val = false;
    var c = 0;
    var ws = 0;
    var vok = 0;
    var child;

    if (isContent(obj))
        vok++;

    for (var i = 0; i < obj.childNodes.length; i++) {
        child = obj.childNodes[i];
        if (isWS(child)) {
            ws++;
        } else {
            if (isText(child)) {
                if (child.data.trim().length >= tc) { //mejorar el conteo evitar ws internos
                    vok++;
                }
            } else {
                if (isContent(child)) { //i.e.: <img/>, <br/> tags
                    vok++;
                } else {
                    if (!isExcluded(child) && !isComment(child)) {
                        if (valid(child))
                            vok++;
                    }
                }
            }
        }
    }
    return(vok > 0);
}

/* calcul the distance between two blocks */
function distance(log1, log2) {

    var closest = {obj: undefined, value: 9999999999};

    ileft = 0
    itop = 1
    iright = 2
    ibottom = 3

    poly1 = getPolygonPoints(log1.dim);

    dleft = PolyK.ClosestEdge(poly1, log2.dim.x, log2.dim.y);
    dtop = PolyK.ClosestEdge(poly1, log2.dim.x, log2.dim.y + log2.dim.h);
    dright = PolyK.ClosestEdge(poly1, log2.dim.x + log2.dim.w, log2.dim.y + log2.dim.h);
    dbottom = PolyK.ClosestEdge(poly1, log2.dim.x + log2.dim.w, log2.dim.y);

    if (dleft.dist < closest.value) {
        closest.obj = blocks[i];
        closest.value = dleft.dist;
    }
    if (dtop.dist < closest.value) {
        closest.obj = blocks[i];
        closest.value = dtop.dist;
    }
    if (dright.dist < closest.value) {
        closest.obj = blocks[i];
        closest.value = dright.dist;
    }
    if (dbottom.dist < closest.value) {
        closest.obj = blocks[i];
        closest.value = dbottom.dist;
    }

    return(closest);
}

/*create a new logic object based on a geometric object geo*/
function createNewLogicalObject(geo, parent) {
    var log = new logicalObject();
    log.parent = parent;
    geo.setLog(log);
    log.addGeometricObject(geo);
    //~ log.setLabel();
    if (parent)
        parent.children.push(log);
    blocks.push(log);
    return(log);
}

/* create a new geometric object based on an element*/
function createNewGeometricObject(element, parent) {
    var geo = new geometricObject();
    geo.addContentElement(element);
    geo.parent = parent;
    if (parent)
        parent.children.push(geo);
    geoList.push(geo);
    return(geo);
}

/*are they? and which aligment exists between log1 and log2: horizontal or vertical?*/
function getAligment(log1, log2) {
    if ((Math.abs(log1.dim.x - log2.dim.x) < dc) || (Math.abs(log1.dim.w - log2.dim.w) < dc)) {
        return("V");
    } else {
        if ((Math.abs(log1.dim.y - log2.dim.y) < dc) || (Math.abs(log1.dim.h - log2.dim.h) < dc)) {
            return("H");
        } else {
            return(null);
        }
    }
}

/*remove subblock*/
function removeLogicObject(log) {
    if (!log)
        return;
    //console.log("delete "+log.id+" "+log.label)
    if (log.parent) {
		for (var i = 0; i < log.geometricObjects.length; i++) {
			var geo = log.geometricObjects[i];
			log.parent.addGeometricObject(geo);
		}
        for (var i = 0; i < log.children.length; i++) {
            var child = log.children[i];
            if (child) {
				log.parent.addChild(child);
                //~ child.parent = log.parent;
                //~ log.parent.children.push(child);
                log.children[i] = undefined;
            }
        }
        var ind = log.parent.children.indexOf(log);
        log.parent.children[ind] = undefined
    }
    blocks.splice(blocks.indexOf(log), 1);
    log.deleteBlock();
    log = undefined

}

/*evaluates a logical object (block)*/
function processLogicalObject(log) {
	var touch = 0;
	var underc = 0;
	var undercc=0;
	var touched = 0;
	var cc=0;
    if (!log)
        return(touched);
    if (log.visited)
        return(touched);
    if (!log.block) return;
    var dep = false;
    var i, j;
    for (i = 0; i < log.children.length; i++) {
        if (log.children[i]) {
            if (log.children[i].gran >= ac) {
                touched+=processLogicStructure(log.children[i])
            } else {
                //~ if (log.children[i].visualCuesPresent) {
                    //~ log.children[i].accept();
                //~ } else 
                if (log.children[i].isSemantic()) {
                    log.children[i].accept();
                } else {
                    touch = 0;
                    var stop = false;
                    if (i < log.children.length - 1)
                        j = i + 1
                    else
                        j = i
                    while (!stop) {
                        if (log.children[j]) {
                            if (log.children[j]) {
								if  (log.children[j].gran < ac) { 
									if (log.children[j].gran > 0) { 
										if (log.children[j] && (i != j)) {
											if (log.children[i].dim && log.children[j].dim) {
												if (log.children[i].dim && log.children[j].dim) {
													if (distance(log.children[i], log.children[j]).value < dc) {
														if (included(getAligment(log.children[i], log.children[j]), ["V", "H"])) {
															log.children[i].mergeWith(log.children[j]);
															touch++;
														} else {
															if ( (PolyK.Contained(log.children[i].bomgeometry(),log.children[j].bomgeometry())) || (PolyK.Contained(log.children[j].bomgeometry(),log.children[i].bomgeometry()))){
																log.children[i].mergeWith(log.children[j]);
																touch++;
															} else {
																if ( (PolyK.Intersect(log.children[i].bomgeometry(),log.children[j].bomgeometry())) || (PolyK.Intersect(log.children[j].bomgeometry(),log.children[i].bomgeometry()))){
																	log.children[i].mergeWith(log.children[j]);
																	touch++;
																}
															}
														}
													}
												} else {
													if (!log.children[i].dim) removeLogicObject(log.children[i]);
													if (!log.children[j].dim) removeLogicObject(log.children[j]);
												}
											} else {
												if (!log.children[i].dim) {
													removeLogicObject(log.children[i]);
												}
												if (!log.children[j].dim) {
													removeLogicObject(log.children[j]);
												}
											}
										}
									} else {
										//~ log.mergeWith(log.children[j]);
										//~ touch++;
										removeLogicObject(log.children[j]);
									}
								}
                            }
                        }
                        j++;
                        stop = (j >= log.children.length);
                    }
                }
            }
            if (log.children[i]) {
				if ((touch == 0) && (log.children[i].gran < ac) && (log.children[i].gran > 0)) {
					log.children[i].accept();
				}
				if ((log.children[i]) && (log.children[i].gran<ac)) {
					underc++;
				}
				if (log.children[i].gran==0) {
					removeLogicObject(log.children[i]);
				}
			}
            touched+=touch;
			cc++;
        }
    }
    
	if ((underc/cc)>0.90) { //90% of innerblocks are under size 
		if (!log.accepted && !log.visited) log.accept();
	}
    if (verbose)
        log.updateBlock();
    return(touched);
}


/* evaluate the logic structure to conform final blocks */
function processLogicStructure(log) {
	var touched=0;
    if (!log)
        return(touched);
    if (log.visited)
        return(touched);

    if (log.type == "PAGE") {
        touched=processLogicalObject(log);
    } else {
        if (log.countChildren() == 1 && !log.isSemantic()) {
			child = log.firstChild();
			//~ child = log.children[0];
			log.mergeWith(child); //hack for HTML5
            //~ removeLogicObject(log);
            touched=processLogicStructure(child);
        } else {
            touched=processLogicalObject(log);
        }
    }
    log.visited = true;
    return(touched);
}

function visitReset() {
	for (var i=0;i<blocks.length;i++) {
		if (blocks[i]) {
			blocks[i].visited=false;
		}
	} 
}

function processLogicStructureMain(log) {
	var touched=-1;
	var k=1;
    while ( touched != 0) {
		console.log("Pass "+k+". "+touched+" blocks were touched");
		visitReset();
		touched=processLogicStructure(log);
		k++;
	}
}


/* ==============================================================*/
/*  LOGIC OBJECT */
/* ==============================================================*/

function logicalObject(obj) {
    this.block = undefined;
    this.id = "L" + blocks.length;
    this.dim = undefined;
    this.parent;
    this.visited = false;
    this.children = [];
    this.type = "";
    this.geometricObjects = [];
    this.label = "ARTICLE";
    this.visualCuesPresent = false;
    this.importance = 0;
    this.gran = 0;
    this.wordcover = 0;
    this.textcover = 0;
    this.htmlcover = 0;
    this.accepted = false;

	this.getPos = function(log) {
		var k=0;
		for (var i=0;i<this.children.length;i++) {
			if (this.children[i]) {
				if (this.children[i]==log) {
					break;
				}
				k++;
			}
		}
		return(k);
	}
	
	this.getId = function() {
		if (this.type == "PAGE") {
			return(1);
		} else {
			if (this.parent) {
				var mypos = this.parent.getPos(this);
				return(this.parent.getId()+"."+(mypos+1));
			} else {
				return("-");
			}
		}
	}
	
    //~ this.setLabelOld = function() { //new HACK for HTML5
		//~ if (!this.dim) return;
        //~ if (this.dim.x < dx) {
            //~ this.label = "LEFT";
        //~ } else {
            //~ if ((documentDim().w - this.dim.w) < dx) {
                //~ this.label = "RIGHT";
            //~ } else {
                //~ if (this.dim.y < dy) {
                    //~ this.label = "TOP";
                //~ } else {
                    //~ if ((documentDim().h - this.dim.h) < dy) {
                        //~ this.label = "BOTTOM";
                    //~ } else {
                        //~ this.label = "STANDARD";
                    //~ }
                //~ }
            //~ }
        //~ }
    //~ }
    this.inVisiblePart = function() {
		return(this.dim.y < $(window).height());// && this.dim.h <= $(window).height());
	}
	this.horizontal = function() {
		return(this.dim.w > this.dim.h);
	}
	this.vertical = function() {
		return(this.dim.h > this.dim.w);
	}
	this.lastVerticalBlock = function() {
		for (var i=0;i<blocks.length;i++) { //ojo blocks no esta actualizado quedan blocks fantasmas
			var b=blocks[i];
			if (b) {
				if (b.dim.b > this.dim.b && b.label!='PAGE') {
					return(false);
				}
			}
		}
		return(true);
	}
	this.firstVerticalBlock = function() {
		for (var i=0;i<blocks.length;i++) { //ojo blocks no esta actualizado quedan blocks fantasmas
			var b=blocks[i];
			if (b) {
				if (b.dim.y < this.dim.y && b.label!='PAGE') {
					return(false);
				}
			}
		}
		return(true);
	}
	this.atLeft = function() {
		return(this.dim.r < $(document).width()/2);
	}
	this.atRight = function() {
		return(this.dim.x > $(document).width()/2);
	}
	this.atTop = function() {
		return(this.dim.b < $(document).height()/3);
	}
	this.atBottom = function() {
		return(this.dim.y > ($(document).height()-$(document).height()/3));
	}
	
	this.inTheMiddle = function() {
		return(!this.atTop() && !this.atBottom() && !this.atLeft() && !this.atRight());
	}
    this.setLabel = function() { //new HACK for HTML5
		if (!this.block) return;
		if (this.type == "PAGE") {
			this.label="PAGE";
			this.updateBlock();
			return;
		};
		var linkTolerance = 0.2;
		var wordTolerance = 0.5;
		var elementTolerance = 0.2;
		var hc = this.countCover() || 1;
		var phc = page.countCover() || 1;
		var wc = this.wordCover() || 0;
		var lc = this.linkCount() || 0;
		var pwc = page.wordCover() || 1;
		if (!this.dim) return;
		console.log(this.id,"WC:",this.wordCover(),"LC:",this.linkCount(),"HC:",this.countCover(),"PA:",this.normalizedArea());
		
		if (true || this.normalizedArea() > ac) {
			if (this.inVisiblePart()) {
				//~ if ((this.dim.x < dc) && ($(document).width() - this.dim.r <= dc) ) {
					// el bloque ocupa todo el width
					if (this.firstVerticalBlock()) {
						if (hc / phc > elementTolerance) {
							if (this.countChildren()>0) {
								this.label="SECTION";
							} else {
								if (this.parent.countChildren()==1) {
									this.label="SECTION";
								} else {
									this.label = "HEADER";
								}
							}
						} else {
							this.label = "HEADER";
						}
					} else {
						if (hc / phc > elementTolerance) {
							if (this.countChildren()>0) {
								this.label = "SECTION";
							} else {
								this.label = "ARTICLE";
							}
						} else {
							if (lc / hc > linkTolerance) {
								this.label = "NAV";
							} else {
								if (this.inTheMiddle()) {
									this.label = "ARTICLE";
								} else {
									if (this.lastVerticalBlock()) {
										this.label = "FOOTER";
									} else {
										if (this.atBottom()) {
											this.label = "FOOTER";
										} else {
											if (this.atLeft() || this.atRight()) {
												this.label = "ASIDE";
											} else {
												this.label = "ARTICLE";
											}
										}
										
									}
								}
							}
						}
					}
				//~ } else {
					//~ if ((lc / hc)>linkTolerance && (wc / pwc)>wordTolerance) {
						//~ if (this.horizontal()) {
							//~ this.label = "NAV";
						//~ } else {
							//~ this.label = "ASIDE";
						//~ }
					//~ } else {
						//~ this.label = "ARTICLE";
					//~ }
				//~ }
			} else {
				if (this.lastVerticalBlock()) {
					this.label = "FOOTER";
				} else {
					this.label = "ARTICLE";
				}
			}
		} 
		this.updateBlock();
		//~ else {
			//~ if (this.horizontal()) {
				//~ if (lc / hc > linkTolerance) {
					//~ this.label = "NAV";
				//~ } else {
					//~ this.label = "ARTICLE";
				//~ }
			//~ } else {
				//~ if (lc / hc > linkTolerance) {
					//~ this.label = "ASIDE";
				//~ } else {
					//~ this.label = "ARTICLE";
				//~ }
			//~ }
		//~ }
		
        //~ if (this.dim.x < dx) {
            //~ this.label = "LEFT";
        //~ } else {
            //~ if ((documentDim().w - this.dim.w) < dx) {
                //~ this.label = "RIGHT";
            //~ } else {
                //~ if (this.dim.y < dy) {
                    //~ this.label = "TOP";
                //~ } else {
                    //~ if ((documentDim().h - this.dim.h) < dy) {
                        //~ this.label = "BOTTOM";
                    //~ } else {
                        //~ this.label = "MIDDLE";
                    //~ }
                //~ }
            //~ }
        //~ }
    }

    this.nextSibling = function() {
        if (this.parent) {
            ind = this.parent.children.indexOf(this);
            if (ind < this.parent.children.length) {
                return(this.parent.children[ind + 1]);
            } else {
                return(null);
            }
        } else {
            return(null);
        }
    }

    this.previousSibling = function() {
        if (this.parent) {
            ind = this.parent.children.indexOf(this);
            if (ind > 0) {
                return(this.parent.children[ind - 1]);
            } else {
                return(null);
            }
        } else {
            return(null);
        }
    }

    //~ this.accept = function() {
        //~ this.clearChildrenBlocks();
    //~ }

    this.accept = function() {
        this.visited = true
        this.accepted = true;
        this.setLabel();
        for (var i = 0; i < this.children.length; i++) {
            if (this.children[i]) {
                this.children[i].accept();
                this.children[i].deleteBlock();
                this.children[i] = undefined;
                //removeLogicObject(this.children[i]);
                //blocks.splice(blocks.indexOf(this.children[i]), 1);
            }
        }
    }

    this.mergeWith = function(log) {
        if (!log)
            return;
        if (this == log)
            return;
        if (log.geometricObjects) {
            for (var i = 0; i < log.geometricObjects.length; i++) {
                this.addGeometricObject(log.geometricObjects[i]);
            }
        }
        if (log.parent) {
            var ind = log.parent.children.indexOf(log);
            log.parent.children[ind] = undefined
        }

        if (verbose)
            log.deleteBlock();

        for (var i = 0; i < log.children.length; i++) {
            child = log.children[i];
            if (child) {
                child.parent = this;
                child.visited = true;
                this.children.push(child);
            }
        }

        if (this.type != "CONTAINER") {
            if (log.type != "DEFAULT") {
                if (this.type != log.type)
                    this.type = log.type;
            }
        }
        this.accept();
        //removeLogicObject(log);
        blocks.splice(blocks.indexOf(log), 1);
        log = undefined
        if (verbose)
            this.updateBlock();
    }

    this.normalizedArea = function() {
		return(relativeArea(this.dim,documentDim()));
    }

    this.bomgeometry = function() {
        return [this.dim.x, this.dim.y, this.dim.w, this.dim.h];
    }

    this.makeid = function()
    {
        var text = "";
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        for (var i = 0; i < 25; i++)
            text += possible.charAt(Math.floor(Math.random() * possible.length));

        return text;
    }

    this.addChild = function(child) {
        child.parent = this;
        this.children.push(child);
    }
	this.removeGeometricObject = function(geo) {
		this.geometricObjects.splice(this.geometricObjects.indexOf(geo), 1);
		if (verbose) this.updateBlock();
	}
	
	this.computeDim = function() {
		this.dim = undefined;
		for (var i=0;i<this.geometricObjects.length;i++) {
			var geo = this.geometricObjects[i];
			if (!this.dim) {
				if (geo.tagName() == "BODY") {
					this.type = 'PAGE';
					this.id = "PAGE";
					this.dim = {x: 0, y: 0, w: documentDim(parent.contentWindow, parent.contentDocument).w, h: documentDim(parent.contentWindow, parent.contentDocument).h}
				} else {
					this.dim = {x: 0, y: 0, w: 0, h: 0}
					this.dim = geo.geometry;
					this.type = geo.type;
				}
				r = getPolygonPoints(this.dim);
			} else {
				r = getPolygonPoints(this.dim).concat(getPolygonPoints(geo.geometry));
				if (included(geo.type, ["CONTAINER", "CONTENT_CONTAINER"])) {
					this.type = geo.type;
				}
			}
		}
		var xs = getX(r);
        var ys = getY(r);

        this.dim.x = Math.min.apply(null, xs);
        this.dim.y = Math.min.apply(null, ys);
        this.dim.w = Math.max.apply(null, xs) - this.dim.x;
        this.dim.h = Math.max.apply(null, ys) - this.dim.y;
	}
	
    this.addGeometricObject = function(geo,dim) {
		var ddim=true;
		if (!(typeof dim === 'undefined')) ddim=dim;
        if (!geo)
            return;
        if (!geo.element && !geo.geometry)
            return;
        geo.setLog(this);
        this.geometricObjects.push(geo);

        var nr;
        var r;
        if (ddim) this.computeDim(geo);

        

        if (verbose && !this.block) {
            this.block = this.insertBlock();
        }
        geo.visited = true;
        var fc;
        var bgc;
        if (geo.element) {
			bgc = contentWindow.getComputedStyle(geo.element, null).getPropertyValue("background-color");
			fc = parseInt(contentWindow.getComputedStyle(geo.element, null).getPropertyValue("font-size"));
			if (bgc != "rgba(0, 0, 0, 0)") {
				this.visualCuesPresent = true;
			}
		
			if (geo.element.parentNode) {
				t = 0
				var pre = $(geo.element).prev()[0];
				var nxt = $(geo.element).next()[0];
				if (nxt) {
					var sfc = parseInt(contentWindow.getComputedStyle(nxt, null).getPropertyValue("font-size"));
					if ((sfc / fc) < 0.8)
						t++;
				}
				if (t > 0)
					this.visualCuesPresent = true;
			}
		}
        /* update values */
        this.gran = this.normalizedArea();
        this.wordcover = this.wordCover();
        this.textcover = this.textCover();
        this.htmlcover = this.countCover();
        
        if (verbose) this.updateBlock();
    }

    this.insertBlock = function() {
        var vc = "";
        this.block = document.createElement('div');
        //~ if (this.visualCuesPresent)
            //~ vc = "VC";
        //~ block.innerHTML = "<span visited='true' class='bomauxtext' style='opacity:1;color:black;font-size:12pt;z-index: 999910000;'>" + this.getId()+"</span>";
        this.block.setAttribute("class", "block");
        //~ block.setAttribute("visited", "true");
        this.block.setAttribute("id", this.makeid());
        //~ block.setAttribute("bid", this.getId());
        //~ block.setAttribute("style","border: 4px solid red");
        contentDocument.body.appendChild(this.block);
        this.updateBlock();
        //~ for (var i=0;i<this.geometricObjects.length;i++) { //hack HTML5
			//~ var geo = this.geometricObjects[i];
			//~ geo.setLog(this);
		//~ }
        return(this.block);
    }

    this.updateBlock = function() {
		if(!this) {console.log("Log obj does not exists");}
		if (!this.block) this.insertBlock();
        var aaa = "G:&nbsp;"+this.gran.toFixed(0);
        var imp = "";
        if (this.countChildren() == 0) {
            this.setOn();
            imp = this.importance;
        } else {
            this.hide();
        }
        var bg = "black";
        if (this.accepted) bg="red";
        if (!this.block) return; //resolver este caso cuando block es nulo en los span

        this.block.innerHTML = "<span visited='true' class='bomauxtext' style='opacity:1;color:black;font-size:12pt;background-color:"+bg+";color:white'>B" + this.id + " "+this.label+"</span>";
        var g = this.dim.x + " " + this.dim.y + " " + this.dim.w + " " + this.dim.h;
        this.block.setAttribute("bomgeometry", g);
        this.block.setAttribute("bomtype", this.type);
        this.block.setAttribute("bid", this.getId());
        color = colors[this.type];
        this.block.setAttribute("style", "border : 4px solid black;z-index: 999910000;position:absolute;background-color:transparent;border-color:" + color + ";color:black;font-weight:bold;opacity:1");
        this.block.style.left = this.dim.x + "px";
        this.block.style.top = this.dim.y + "px";
        this.block.style.width = this.dim.w + "px";
        this.block.style.height = this.dim.h + "px";
        for (var i=0;i<this.geometricObjects.length;i++) { //hack HTML5
			var geo = this.geometricObjects[i];
			geo.setLog(this);
		}
    }

    this.setOn = function() {
        if (!this.block)
            return;
        if (this.label=="PAGE")
            c = "yellow";
        else 
			c="red";
        this.block.style.backgroundColor = c;
        this.block.style.opacity = "0.5";
        this.block.style.border = "4px solid red";
        this.block.style.color = "white";
    }

    this.setOff = function() {
        if (!this.block)
            return;
        this.block.style.backgroundColor = "transparent";
        this.block.style.color = "black";
        this.block.style.opacity = "1";
        this.block.style.border = "4px solid "+colors[this.type]
    }
    this.hide = function() {
        if (!this.block)
            return;
        this.block.style.backgroundColor = "transparent";
        this.block.style.opacity = "1";
        this.block.style.border = "0px solid transparent";
    }
    this.deleteBlock = function() {
        if (this.block)
            contentDocument.body.removeChild(this.block);
        this.block = undefined;
    }
    this.countChildren = function() {
        var cont = 0;
        for (var i = 0; i < this.children.length; i++) {
            if (this.children[i]) {
                cont++;
            }
        }
        return(cont);
    }
    this.countCover = function() {
        var cont = 0;
        for (var i = 0; i < this.geometricObjects.length; i++) {
            cont += this.geometricObjects[i].countCover();
        }
        return(cont);
    }
    this.textCover = function() {
		var cont=0;
		for (var i=0;i<this.geometricObjects.length;i++) {
			cont+=this.geometricObjects[i].countTextCover();
		}
		return(cont);
	}
    this.wordCover = function() {
		var cont=0;
		for (var i=0;i<this.geometricObjects.length;i++) {
			cont+=this.geometricObjects[i].wordCover();
		}
		return(cont);
	}
    this.linkCount = function() {
		var cont=0;
		for (var i=0;i<this.geometricObjects.length;i++) {
			cont+=this.geometricObjects[i].linkCount();
		}
		return(cont);
	}
    this.terminal = function() {
        return(this.countChildren() == 0);
    }
    this.isSemantic = function() {
        return(isSemantic(this.geometricObjects[0].element));
    }
    this.coverElement = function(elem) {
		var ed = getRect(elem);
		if ((this.dim.x<=ed.x) && (ed.r<=this.dim.r) && (this.dim.r>=ed.x) && (this.dim.x<=ed.r)) {
			if ((this.dim.y<=ed.y) && (ed.b<=this.dim.b) && (this.dim.b>=ed.y) && (this.dim.y<=ed.b)) {
				return(true);
			}
			if (included(elem.tagName,['TR','TD'])) {
				if (PolyK.ContainsPoint(getPolygonPoints(this.dim),ed.x,ed.y) && PolyK.ContainsPoint(getPolygonPoints(this.dim),ed.r,ed.y)) {
					return(true); //fucking tables
				}
			}
		} else {
			if (included(elem.tagName,['TR','TD'])) {
				if (PolyK.ContainsPoint(getPolygonPoints(this.dim),ed.x,ed.y) && PolyK.ContainsPoint(getPolygonPoints(this.dim),ed.r,ed.y)) {
					return(true); //fucking tables
				}
			}
		}
		return(false);
	}
	this.firstChild = function() {
		for (var i=0;i<this.children.length;i++) {
			var child = this.children[i];
			if (child) {
				return(child);
			}	
		}
	}
}

/* relative area granularity */

function relativeArea(dim,docdim) {
		var d=0;
		
		var x = Math.round(100*dim.x/docdim.w);
		var w = Math.round(100*dim.w/docdim.w);
		var y = Math.round(100*dim.y/docdim.h);
		var h = Math.round(100*dim.h/docdim.h);
		
		var dh = w;
		var dv = h;
		//~ var dh = w-x;
		//~ var dv = h-y;
		
		d = Math.round(((dh+dv)/2)/10);
		
		return(d);
}


function relativeArea2(dim,docdim) {
		var cont = 0;
		for (var i = 0; i < 100; i += 10) {
			if ((100 * dim.w / docdim.w) > i)
				cont++;
		}
		var dw = cont;
		cont = 0;
		for (var i = 0; i < 100; i += 10) {
			if ((100 * dim.h / docdim.h) > i)
				cont++;
		}
		var dh = cont;

		var d=0;
		if (dw!=0 && dh!=0) d = Math.round((dw+dh)/2);
		return(d);
}

function relativeAreaElement(element) {
	return(relativeArea(getRect(element),documentDim()))
}

/* ==============================================================*/
/*  GEOMETRIC OBJECT */
/* ==============================================================*/

function geometricObject() {
    this.children = [];
    this.parent = undefined;
    this.element = undefined;
    this.type = undefined;
    this.geometry = undefined;
    this.area = undefined;
    this.id = undefined;
    this.visited = false;
    this.logicObject = undefined;
    
    this.tagName = function() {
		if (this.element) {
			if (this.element.tagName) {
				return(this.element.tagName.toUpperCase());
			}
		}
	}
	
	this.setLog = function(log){
		this.logicObject = log;
		this.element.setAttribute("bid",this.logicObject.id); //hack for HTML5
		var all = this.element.getElementsByTagName("*");
		for (var i=0;i<all.length;i++) {
			var node = all[i];
			if (node.nodeType==1) {
				node.setAttribute("bid",this.logicObject.id); //hack for HTML5
			}
		}
	}
	
    this.addContentElement = function(element) {
        this.element = element;
        this.bt = BOMType(this.element);
        //~ if (this.bt) {
            this.type = this.bt;
            this.geometry = getRect(this.element);
            this.id = "C" + (1000 + Math.random(1000));
        //~ }
    }
    this.getGeometry = function() {
        return(this.dim.x + " " + this.dim.y + " " + this.dim.w + " " + this.dim.h);
    }
    this.countCover = function() {
        return($(this.element).find('*').length)
    }
    this.countTextCover = function() {
		var text = $(this.element).text();
		return(text.length)
	}
    this.wordCover = function() {
		var text = $(this.element).text();
		return(countWords(text));
	}
    this.linkCount = function() {
		var links = $(this.element).find("a");
		var onclicks = $(this.element).find("[onclick]");
		return(links.length + onclicks.length);
	}
}

/* ==============================================================*/
/*  PROCESS IMPORTANCE OF BLOCKS */
/* ==============================================================*/

function processImportance(block) {
    if (block.terminal()) {
        block.importance = grid.getImportance(block);
        if (verbose)
            block.updateBlock();
    } else {
        for (var i = 0; i < block.children.length; i++) {
            if (block.children[i]) {
                processImportance(block.children[i]);
            }
        }
    }
}

function buildGrid() {
    grid = new Grid(gridRows, gridCols);
    grid.init(1);
    var wheight = window.innerHeight || $(window).height();
    var wwidth = window.innerWidth || $(window).width();
    var visibleRow = grid.getRowFromGeometry(wheight);
    var visibleCol = grid.getColFromGeometry(wwidth);
    grid.fillVisiblePart(0, 0, visibleRow, visibleCol, 1);
    //grid.fillRestOfPage(visibleRow,1);//gridRows-visibleRow
    if (verbose && showGrid)
        grid.draw();
}

function clearGrid() {
    if (verbose && showGrid)
        grid.clear();
}

/* ==============================================================*/
/*  GRID MATRIX OBJECT */
/* ==============================================================*/

function Grid(rows, cols) {
    this.rows = rows;
    this.cols = cols;
    this.data = [];
    this.width = $(document).width();//documentDim().w;
    this.height = $(document).height(); //documentDim().h;
    this.gapRows = this.height / this.rows;
    this.gapCols = this.width / this.cols;

    this.getRowFromGeometry = function(value) {
        return parseInt(value / this.gapRows);
    }

    this.getColFromGeometry = function(value) {
        return parseInt(value / this.gapCols);
    }

    this.init = function(initvalue) {
        for (var i = 0; i < this.rows; i++) {
            var row = [];
            for (var j = 0; j < this.cols; j++) {
                row.push(initvalue);
            }
            this.data.push(row);
        }
    }

    this.fillRestOfPage = function(startRow, startValue) {
        for (var i = startRow; i < this.rows; i++) {
            for (var j = 0; j < this.cols; j++) {
                this.set(i, j, startValue)
            }
            //startValue--;
        }
    }

    this.fillVisiblePart = function(row, col, n, m, value) {

        if (row >= n || col >= m) {
            return;
        }

        var rf = row;
        var rl = n;
        var cf = col;
        var cl = m;

        for (var r = rf; r < rl; r++) {
            this.set(r, cf, value);
            this.set(r, cl - 1, value)
        }
        for (var c = cf; c < cl; c++) {
            this.set(rf, c, value);
            this.set(rl - 1, c, value);
        }

        this.fillVisiblePart(row + 1, col + 1, n - 1, m - 1, value + 1);
    }

    this.get = function(i, j) {
        return(this.data[i][j]);
    }

    this.set = function(i, j, value) {
        this.data[i][j] = value;
    }

    this.drawHorizontalLine = function(x1, y1, width, color) {
        var id = 'c_' + new Date().getTime() + (Math.floor((Math.random() * 1000) + 1));
        var line = "<div id='" + id + "'class='bomgrid_element'>&nbsp;</div>";

        $('body').append(line);

        $('#' + id).css({
            left: x1,
            top: y1,
            width: width,
            height: '1px',
            position: 'absolute',
            backgroundColor: color,
            'z-index': '9999999999999'
        });

    };

    this.drawVerticalLine = function(x1, y1, height, color) {
        var id = 'c_' + new Date().getTime() + (Math.floor((Math.random() * 1000) + 1));
        var line = "<div id='" + id + "'class='bomgrid_element'>&nbsp;</div>";

        $('body').append(line);

        $('#' + id).css({
            left: x1,
            top: y1,
            height: height,
            width: '1px',
            position: 'absolute',
            backgroundColor: color,
            'z-index': '9999999999999'
        });

    };

    this.drawText = function(x, y, text) {
        var id = 'c_' + new Date().getTime() + (Math.floor((Math.random() * 1000000) + 1));
        var line = "<div id='" + id + "'class='bomgrid_element'>&nbsp;" + text + "&nbsp;</div>";

        $('body').append(line);

        $('#' + id).css({
            left: x,
            top: y,
            position: 'absolute',
            'font-size': '30px',
            'box-shadow': '2px 2px 5px #888',
            'background-color': 'blue',
            'color': 'white',
            'font-weight': 'bold',
            'z-index': '9999999999999'
        });
    }

    this.draw = function() {

        for (var k = 1; k < this.rows; k++) {
            this.drawHorizontalLine(0, k * this.gapRows, this.width, "red");
        }
        for (var k = 1; k < this.cols; k++) {
            this.drawVerticalLine(k * this.gapCols, 0, this.height, "red");
        }
        for (var i = 0; i < this.rows; i++) {
            for (var j = 0; j < this.cols; j++) {
                this.drawText(j * this.gapCols + (this.gapCols / 2) - 20, i * this.gapRows + (this.gapRows / 2) - 20, this.get(i, j));
            }
        }
    }

    this.clear = function() {
        $('body').find('.bomgrid_element').remove();
    }

    this.getImportance = function(block) {
        var initialXpos = parseInt(block.dim.x / this.gapCols);
        var initialYpos = parseInt(block.dim.y / this.gapRows);
        var finalXpos = parseInt((block.dim.w + block.dim.x) / this.gapCols);
        var finalYpos = parseInt((block.dim.h + block.dim.y) / this.gapRows);
        var acum = 0;
        for (var i = initialYpos; i <= finalYpos; i++) {
            for (var j = initialXpos; j <= finalXpos; j++) {
                acum += this.get(i, j);
            }
        }
        return(acum);
    }
}


/****** building Wprima functions *******/
function getWPrima(log) {
    if (!log)
        return;
    var prima = "";
    var type;
    if (log.terminal()) {
        type = "BLOCK";
    } else {
        type = "LAYOUTBLOCK";
    }
    if (log.type == "PAGE") {
        prima += "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n<html>\n<head>\n</head>\n<body>\n";
        type = "PAGE";
    } else {
        var css = "";
        var html = "";
        for (var j = 0; j < log.geometricObjects.length; j++) {
            var geo = log.geometricObjects[j];
            //~ if (geo) {
                //~ var lcss = "";
                //~ var cs = getComputedStyle(geo.element);
                //~ for (var k = 0; k < cs.length; k++) {
                    //~ var at = cs.item(k);
                    //~ lcss += at + ":" + cs.getPropertyValue(at) + ";";
                    //~ css += at + ":" + cs.getPropertyValue(at) + ";";
                //~ }
                //~ if (!geo.element.hasAttribute("css_added")) {
                    //geo.element.setAttribute("style", lcss);
                //~ }
                //~ geo.element.setAttribute("css_added", "true");
            //~ }
            //~ var all = geo.element.getElementsByTagName("*");
            //~ for (var k = 0; k < all.length; k++) {
                //~ var child = all[k];
                //~ var lcss = "";
                //~ if (!child.hasAttribute("css_added")) {
                    //~ var cs = getComputedStyle(child);
                    //~ for (var ki = 0; ki < cs.length; ki++) {
                        //~ var at = cs.item(ki);
                        //~ lcss += at + ":" + cs.getPropertyValue(at) + ";";
                    //~ }
                    //~ //child.setAttribute("style", lcss);
                //~ }
                //~ child.setAttribute("css_added", "true");
            //~ }
            html += geo.element.outerHTML;
        }
    }
    var r = log.dim.x + " " + log.dim.y + " " + log.dim.w + " " + log.dim.h
    prima += "<" + type + " geometry='" + r + "' importance='" + grid.getImportance(log) + "' id='"+log.id+"' label='"+log.label+"'>\n";
    if (!log.terminal()) {
        for (var i = 0; i < log.children.length; i++) {
            var child = log.children[i];
            if (child) {
                prima += getWPrima(child)
            }
        }
    } else {
        prima += html;
    }

    prima += "</" + type + ">\n"
    if (log.type == "PAGE") {
        prima += "</body>\n</html>";
    }

    return(prima);
}


/** RECORD **/

function getRecord(obj,srcurl) {
	if (!obj) return;
	var s="";
	if (obj.terminal()) {
		return "BOM,"+sniff()+",none,"+srcurl+","+documentDim().w+","+documentDim().h + ","+ georoot.countCover() + "," + ac + ","+obj.id+","+obj.dim.x+","+obj.dim.y+","+obj.dim.r+","+obj.dim.b+","+obj.countCover()+","+obj.wordCover()+"\n";
	} else {
		for (var i=0;i<obj.children.length;i++) {
			var child = obj.children[i];
			if (child) {
				s+=getRecord(child,srcurl);
			}
		}
	}
	return(s)
}

/** DESCRIPTOR **/

function getDescriptor(obj) {
	if (!obj) return;
	var s="";
	
	s+= obj.id+"="+obj.label+",";
	
	for (var i=0;i<obj.children.length;i++) {
		var child = obj.children[i];
		if (child) {
			s+=getDescriptor(child);
		}
	}
	
	return(s)
}

/* general functions */
/* included obj in arr?*/
function included(obj, arr) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] == obj) {
            return(true);
        }
    }
    return(false);
}


function sniff() {
var nVer = navigator.appVersion;
var nAgt = navigator.userAgent;
var browserName  = navigator.appName;
var fullVersion  = ''+parseFloat(navigator.appVersion); 
var majorVersion = parseInt(navigator.appVersion,10);
var nameOffset,verOffset,ix;

// In Opera, the true version is after "Opera" or after "Version"
if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
 browserName = "opera";
 fullVersion = nAgt.substring(verOffset+6);
 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
   fullVersion = nAgt.substring(verOffset+8);
}
// In MSIE, the true version is after "MSIE" in userAgent
else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
 browserName = "iexplore";
 fullVersion = nAgt.substring(verOffset+5);
}
// In Chrome, the true version is after "Chrome" 
else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
 browserName = "chrome";
 fullVersion = nAgt.substring(verOffset+7);
}
// In Safari, the true version is after "Safari" or after "Version" 
else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
 browserName = "safari";
 fullVersion = nAgt.substring(verOffset+7);
 if ((verOffset=nAgt.indexOf("Version"))!=-1) 
   fullVersion = nAgt.substring(verOffset+8);
}
// In Firefox, the true version is after "Firefox" 
else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
 browserName = "firefox";
 fullVersion = nAgt.substring(verOffset+8);
}
// In most other browsers, "name/version" is at the end of userAgent 
else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) < 
          (verOffset=nAgt.lastIndexOf('/')) ) 
{
 browserName = nAgt.substring(nameOffset,verOffset);
 fullVersion = nAgt.substring(verOffset+1);
 if (browserName.toLowerCase()==browserName.toUpperCase()) {
  browserName = navigator.appName;
 }
}
// trim the fullVersion string at semicolon/space if present
if ((ix=fullVersion.indexOf(";"))!=-1)
   fullVersion=fullVersion.substring(0,ix);
if ((ix=fullVersion.indexOf(" "))!=-1)
   fullVersion=fullVersion.substring(0,ix);

majorVersion = parseInt(''+fullVersion,10);
if (isNaN(majorVersion)) {
 fullVersion  = ''+parseFloat(navigator.appVersion); 
 majorVersion = parseInt(navigator.appVersion,10);
}

return(browserName);
}

function countWords(txt) {
	if ($.trim(txt)=="") 
		return(0);
	else
		return txt.replace( /[^\w ]/g, "" ).split( /\s+/ ).length
}
