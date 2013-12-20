function rectLib() {

	this.data = undefined;

	this.init = function(win,doc)  {
		this.window = win;
		if (doc) 
			this.document = doc;
		else
			this.document = this.window.document
	}
	this.draw = function() {
		this.document.body.appendChild(this.data);
	}
	this.build = function(x,y,w,h,cont,id,border,background) {
		this.data = this.document.createElement('div');
		this.setId(id);
		this.setContent(id + "<br>" + cont);
		this.move(x,y);
		this.resize(w,h);
		this.rectInit();
		this.applyStyle('border',border);
		this.applyStyle('background',background);
		this.draw();
		return(this);
	}
	
	this.deleteRect = function() {
		var ind = this.rects.indexOf(this.data);
		this.document.body.removeChild(this.data);
	}
	
	this.resize = function(w,h) {
		this.data.style.width = w + "px";
		this.data.style.height = h + "px";
	}
	this.move = function(x,y) {
		this.data.style.left = x + "px";
		this.data.style.top = y + "px";
	}
	this.applyStyle = function(selector,sty) {
		if (selector=='border')
			this.data.style.border = sty;
		else {
			//~ this.data.style.opacity = "0.5";
			this.data.style.background = sty;
		}
	}
	this.rectInit = function() {
		this.data.style.zIndex = 100000;
		this.data.style.position = "absolute";
	}
	this.setContent = function(cont) {
		this.data.style.color="white";
		this.data.innerHTML = cont;
	}
	this.setId = function(id) {
		if (id) 
			this.data.setAttribute("id",id);
		else
			this.data.setAttribute("id","reclib_" + Math.floor((Math.random()*1000)+1));
	}
}
