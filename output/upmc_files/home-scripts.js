// Gestion affichage sMenu Accesdirect
function initDirectAccess(){
	
	//Au chargement : cache les menus déroulants
	$("#submenu-directaccess").css("display","none");
	$("#submenu-whoareyou").css("display","none");
	
	// place les menus déroulants en position:absolute
	$(".directaccesslinks ul").css("position","absolute");

	//Au survol : affiche sous-menus
	$(".directaccess, #submenu-directaccess, #submenu-directaccess ul").mouseover(function(){  $("#submenu-directaccess").css("display","block");	});
	$(".whoareyou, #submenu-whoareyou, #submenu-whoareyou ul ").mouseover(function(){ $("#submenu-whoareyou").css("display","block");	});
	//effets
	//$(".directaccess").mouseover(function(){ $("#submenu-directaccess").fadeIn("0.5"); });
	
	//fermeture des sous menus
	$("#submenu-directaccess, #submenu-whoareyou, .directaccess, .whoareyou"  ).mouseout( function() { $("#submenu-directaccess").css("display","none"); $("#submenu-whoareyou").css("display","none"); } );
}


// Gestion Carroussel
function initCarroussel(){
	$(".Applications_1").accessNews({
		newsHeadline: carrouselTitle,
		newsSpeed: "normal",
		newsGroup: "1"
		
	});
	/*

	newsHeadline: "title"  (String)          |  Each unique carroussel (id) or set of carroussels (class) can receive a title.
	newsSpeed: "normal"          (String/Integer)  |  "slow","normal","fast", or an integer, with 1 being the fastest animation.

	*/
	
	// Tooltips
	//$(".item a").Tooltip({ track: true, delay: 200, showURL: false, showBody: " - " });
	
	// Spécif hauteur du carroussel;
	$(".contentcolumn .events").css("height","164px");
	
	if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){
		var ieversion=new Number(RegExp.$1)
		if (ieversion=6) {		
				$(".contentcolumn .events .container").css("-width","485px");
		}
	}
};


// ON LOAD
$(document).ready(function(){
		initDirectAccess();
		initCarroussel();
});


