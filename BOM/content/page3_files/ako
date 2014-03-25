function rsi_img(p,u,c){if(u.indexOf(location.protocol)==0){var i=new Image(2,3);if(c){i.onload=c;}
i.src=u;p[p.length]=i;}}
function rsi_simg(p,s,i){if(i<s.length){rsi_img(p,s[i],function(){rsi_simg(p,s,i+1);});}}
function rsi_req_pix(l,s){var w=window;if(typeof(w.rsi_imgs)=="undefined"){w.rsi_imgs=[];}
if(typeof(w.rsi_simgs)=="undefined"){w.rsi_simgs=[];}
var a=w.rsi_imgs;var b=w.rsi_simgs;var i;for(i=0;i<l.length;++i){if(s){b[b.length]=l[i];}else{rsi_img(a,l[i]);}}
if(s){rsi_simg(a,b,0);}}
rsi_req_pix([],0);rsi_req_pix([],1);